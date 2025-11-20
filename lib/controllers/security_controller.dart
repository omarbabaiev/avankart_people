import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:avankart_people/services/pin_service.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/utils/api_response_parser.dart';

class SecurityController extends GetxController {
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Observable state
  final RxBool isPinEnabled = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs; // Session authentication durumu

  @override
  void onInit() {
    super.onInit();
    _loadSecuritySettings();
    _checkBiometricAvailability();
  }

  // Güvenlik ayarlarını yükle
  Future<void> _loadSecuritySettings() async {
    try {
      // PIN durumu artık storage'dan değil backend'den (user.pinBool) okunur
      bool backendPinEnabled = false;
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        backendPinEnabled = home.user?.pinBool == true;
      }
      final String? biometricEnabled =
          await _storage.read(key: SecureStorageConfig.biometricEnabledKey);

      isPinEnabled.value = backendPinEnabled;
      isBiometricEnabled.value = biometricEnabled == 'true';
    } catch (e) {
      debugPrint('Error loading security settings: $e');
    }
  }

  // Biyometrik authentication mevcutluğunu kontrol et
  Future<void> _checkBiometricAvailability() async {
    try {
      debugPrint('\n╔═══════════════════════════════════════════════════╗');
      debugPrint(
          '║ [SECURITY CONTROLLER] 🔍 Checking Biometric Availability ║');
      debugPrint('╚═══════════════════════════════════════════════════╝');
      debugPrint(
          '[SECURITY CONTROLLER] 📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');

      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      debugPrint('[SECURITY CONTROLLER] 📊 Biometric Check Results:');
      debugPrint('[SECURITY CONTROLLER]   - canCheckBiometrics: $isAvailable');
      debugPrint(
          '[SECURITY CONTROLLER]   - Available Biometrics: $availableBiometrics');
      debugPrint(
          '[SECURITY CONTROLLER]   - Available Count: ${availableBiometrics.length}');

      // Platform'a göre uygun biyometrik türünü kontrol et
      bool hasRequiredBiometric = false;
      if (Platform.isIOS) {
        // iOS'da Face ID veya Touch ID kontrolü
        hasRequiredBiometric =
            availableBiometrics.contains(BiometricType.face) ||
                availableBiometrics.contains(BiometricType.fingerprint);
        debugPrint('[SECURITY CONTROLLER] 🍎 iOS Biometric Check:');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Face ID: ${availableBiometrics.contains(BiometricType.face)}');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Touch ID: ${availableBiometrics.contains(BiometricType.fingerprint)}');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Required: $hasRequiredBiometric');
      } else if (Platform.isAndroid) {
        // Android'de parmak izi kontrolü - hem fingerdebugPrint hem de strong biometric kontrol et
        hasRequiredBiometric =
            availableBiometrics.contains(BiometricType.fingerprint) ||
                availableBiometrics.contains(BiometricType.strong);
        debugPrint('[SECURITY CONTROLLER] 🤖 Android Biometric Check:');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Fingerprint: ${availableBiometrics.contains(BiometricType.fingerprint)}');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Strong: ${availableBiometrics.contains(BiometricType.strong)}');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Weak: ${availableBiometrics.contains(BiometricType.weak)}');
        debugPrint(
            '[SECURITY CONTROLLER]   - Has Required: $hasRequiredBiometric');
      }

      final bool finalResult = isAvailable && hasRequiredBiometric;
      isBiometricAvailable.value = finalResult;

      debugPrint('[SECURITY CONTROLLER] ✅ Final Result:');
      debugPrint('[SECURITY CONTROLLER]   - isAvailable: $isAvailable');
      debugPrint(
          '[SECURITY CONTROLLER]   - hasRequiredBiometric: $hasRequiredBiometric');
      debugPrint(
          '[SECURITY CONTROLLER]   - Final Biometric Available: $finalResult');
      debugPrint('╔═══════════════════════════════════════════════════╗');
      debugPrint('║ [SECURITY CONTROLLER] ✅ Biometric Check Complete ║');
      debugPrint('╚═══════════════════════════════════════════════════╝\n');
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────┐');
      debugPrint('│ [SECURITY CONTROLLER] ❌ Biometric Check Error  │');
      debugPrint('└─────────────────────────────────────────────────┘');
      debugPrint('[SECURITY CONTROLLER] 🚫 Error Details:');
      debugPrint('[SECURITY CONTROLLER]   - Type: ${e.runtimeType}');
      debugPrint('[SECURITY CONTROLLER]   - Message: $e');
      debugPrint(
          '[SECURITY CONTROLLER]   - Setting isBiometricAvailable to false');
      isBiometricAvailable.value = false;
    }
  }

  // PIN kod aktif/pasif et
  Future<void> togglePinCode({bool skipVerification = false}) async {
    try {
      if (isPinEnabled.value) {
        // PIN kodunu devre dışı bırakmadan önce PIN doğrulaması yap
        if (!skipVerification) {
          final result = await Get.toNamed(
            AppRoutes.enterPinCode,
            arguments: {
              'verifyOnly': true,
              'allowBack': true,
            },
          );

          // PIN doğrulanmadıysa işlemi iptal et
          if (result != true) {
            debugPrint(
                '[SECURITY] PIN verification failed, cancelling disable');
            return;
          }
        }

        // PIN kodunu devre dışı bırak (backend)
        try {
          final pinService = PinService();
          final ok = await pinService.setPinStatus(status: false);
          if (!ok) {
            SnackbarUtils.showErrorSnackbar('pin_code_error'.tr);
            return;
          }
          isPinEnabled.value = false; // UI güncellemesi
          SnackbarUtils.showSuccessSnackbar('pin_code_disabled'.tr);
        } catch (e) {
          final msg = ApiResponseParser.parseDioError(e);
          SnackbarUtils.showErrorSnackbar(msg);
          return;
        }

        // PIN kod devre dışıysa biyometrik de devre dışı bırak
        if (isBiometricEnabled.value) {
          // Biometric'i de disable et (PIN doğrulaması zaten yapıldı, skip verification)
          await _storage.delete(key: SecureStorageConfig.biometricEnabledKey);
          isBiometricEnabled.value = false;
          debugPrint(
              '[SECURITY] Biometric automatically disabled (PIN disabled)');
        }
      } else {
        // PIN kod ayarlama ekranına git (settings'den geldiği için geri gidebilsin)
        final result = await Get.toNamed(AppRoutes.setPinCode,
            arguments: {'allowBack': true});
        // Başarılı kurulumu takiben backend'le senkronize ol (pin_bool güncellenmiş olabilir)
        if (result == true && Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().refreshUserData();
          await _loadSecuritySettings(); // switch'i backend pin_bool ile senkronize et
        }
        return;
      }
      // Disable akışında da backend verisini tazele
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refreshUserData();
        await _loadSecuritySettings();
      }
    } catch (e) {
      debugPrint('Error toggling PIN code: $e');
      SnackbarUtils.showErrorSnackbar('pin_code_error'.tr);
    }
  }

  // Biyometrik authentication aktif/pasif et
  Future<void> toggleBiometric(
      [bool? value,
      bool skipAuth = false,
      bool skipPinVerification = false]) async {
    try {
      if (!isPinEnabled.value) {
        SnackbarUtils.showErrorSnackbar('pin_code_warning'.tr);
        return;
      }

      final bool newValue = value ?? !isBiometricEnabled.value;

      debugPrint(
          '[SECURITY] toggleBiometric called - newValue: $newValue, skipAuth: $skipAuth, skipPinVerification: $skipPinVerification');

      if (newValue) {
        // Enable işlemi
        // Eğer skipAuth true ise (PIN doğrulama yapıldıysa) direkt enable et
        // Değilse biometric authentication test et
        bool shouldEnable = skipAuth;

        if (!skipAuth) {
          debugPrint('[SECURITY] Testing biometric authentication...');
          final bool didAuthenticate = await _authenticateWithBiometric();
          shouldEnable = didAuthenticate;
          debugPrint('[SECURITY] Biometric auth result: $didAuthenticate');
        } else {
          debugPrint(
              '[SECURITY] Skipping biometric auth (PIN already verified)');
        }

        if (shouldEnable) {
          debugPrint('[SECURITY] Enabling biometric...');
          await _storage.write(
              key: SecureStorageConfig.biometricEnabledKey, value: 'true');
          isBiometricEnabled.value = true;
          debugPrint(
              '[SECURITY] Biometric enabled successfully: ${isBiometricEnabled.value}');

          SnackbarUtils.showSuccessSnackbar(Platform.isIOS
              ? 'face_id_enabled'.tr
              : 'fingerdebugPrint_enabled'.tr);
        } else {
          debugPrint('[SECURITY] Biometric enable failed');
          isBiometricEnabled.value = false;
        }
      } else {
        // Disable işlemi - PIN kod ekranına git, orada biometric otomatik açılacak
        if (!skipPinVerification) {
          debugPrint(
              '[SECURITY] Navigating to PIN code screen for biometric disable...');

          // PIN kod ekranına git (orada biometric otomatik açılacak)
          final result = await Get.toNamed(
            AppRoutes.enterPinCode,
            arguments: {
              'verifyOnly': true,
              'allowBack': true,
              'forDisable': true, // Biometric disabled işlemi için
            },
          );

          // PIN veya biometric doğrulanmadıysa işlemi iptal et
          if (result != true) {
            debugPrint(
                '[SECURITY] Authentication failed, cancelling biometric disable');
            return;
          }
          debugPrint(
              '[SECURITY] Authentication successful (PIN or biometric), proceeding with disable');
        }

        debugPrint('[SECURITY] Disabling biometric...');
        await _storage.delete(key: SecureStorageConfig.biometricEnabledKey);
        isBiometricEnabled.value = false;
        debugPrint('[SECURITY] Biometric disabled');

        SnackbarUtils.showSuccessSnackbar(Platform.isIOS
            ? 'face_id_disabled'.tr
            : 'fingerdebugPrint_disabled'.tr);
      }
    } catch (e) {
      debugPrint('[SECURITY] Error toggling biometric: $e');
      SnackbarUtils.showErrorSnackbar('biometric_error'.tr);
      isBiometricEnabled.value = false;
    }
  }

  // Biyometrik authentication ile doğrula (public wrapper)
  Future<bool> authenticateWithBiometric() async {
    return await _authenticateWithBiometric();
  }

  // Biyometrik authentication ile doğrula (private implementation)
  Future<bool> _authenticateWithBiometric() async {
    try {
      // Platform'a göre uygun biyometrik türünü belirle
      List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      List<BiometricType> allowedBiometrics = [];

      if (Platform.isIOS) {
        // iOS'da Face ID öncelikli, Touch ID ikinci seçenek
        if (availableBiometrics.contains(BiometricType.face)) {
          allowedBiometrics = [BiometricType.face];
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          allowedBiometrics = [BiometricType.fingerprint];
        }
      } else if (Platform.isAndroid) {
        // Android'de parmak izi veya strong biometric
        if (availableBiometrics.contains(BiometricType.fingerprint)) {
          allowedBiometrics = [BiometricType.fingerprint];
        } else if (availableBiometrics.contains(BiometricType.strong)) {
          allowedBiometrics = [BiometricType.strong];
        }
      }

      if (allowedBiometrics.isEmpty) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: Platform.isIOS
            ? (allowedBiometrics.contains(BiometricType.face)
                ? 'face_id_verify'.tr
                : 'touch_id_verify'.tr)
            : 'fingerdebugPrint_verify'.tr,
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        // Biometric authentication başarılı, session flag'i set et
        isAuthenticated.value = true;
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  // PIN kod ile doğrula
  Future<bool> authenticateWithPin(String pin) async {
    try {
      // Backend ile doğrula
      final pinService = PinService();
      final bool isValid = await pinService.checkPin(pinCode: pin);
      if (isValid) {
        // Authentication başarılı, session flag'i set et
        isAuthenticated.value = true;
      }
      return isValid;
    } catch (e) {
      debugPrint('PIN authentication error: $e');
      final message = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(message);
      return false;
    }
  }

  // PIN kod kaydet
  Future<void> savePinCode(String pin) async {
    try {
      // Backend'de PIN'i enable et ve yeni PIN'i gönder
      final pinService = PinService();
      final ok = await pinService.setPinStatus(status: true, newPin: pin);
      if (!ok) {
        SnackbarUtils.showErrorSnackbar('pin_code_save_error'.tr);
        return;
      }
      isPinEnabled.value = true; // UI state
      debugPrint('PIN code enabled via backend.');
      // Kurulumdan sonra backend'le senkronize ol ve switch'i güncelle
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refreshUserData();
        await _loadSecuritySettings();
      }
    } catch (e) {
      debugPrint('Error saving PIN code: $e');
      throw Exception('PIN kod kaydedilemedi');
    }
  }

  // Uygulama açılışında authentication kontrolü
  Future<bool> shouldAuthenticate() async {
    return isPinEnabled.value || isBiometricEnabled.value;
  }

  // Uygulama açılışında authentication yap
  Future<bool> authenticateForAppAccess() async {
    if (!isPinEnabled.value && !isBiometricEnabled.value) {
      return true; // Hiçbir güvenlik ayarı yoksa direkt geç
    }

    if (isBiometricEnabled.value && isBiometricAvailable.value) {
      // Önce biyometrik dene
      final bool biometricResult = await _authenticateWithBiometric();
      if (biometricResult) {
        return true;
      }
    }

    if (isPinEnabled.value) {
      // PIN kod ekranını göster
      return await _showPinCodeScreen();
    }

    return false;
  }

  // PIN kod ekranını göster ve sonucu bekle
  Future<bool> _showPinCodeScreen() async {
    final result = await Get.toNamed(AppRoutes.enterPinCode);
    return result == true;
  }

  // PIN kod ayarlarını yenile
  Future<void> refreshSettings() async {
    debugPrint('\n╔═══════════════════════════════════════════════════╗');
    debugPrint('║ [SECURITY CONTROLLER] 🔄 Refreshing Settings      ║');
    debugPrint('╚═══════════════════════════════════════════════════╝');

    await _loadSecuritySettings();
    await _checkBiometricAvailability();

    debugPrint('[SECURITY CONTROLLER] 📊 Settings Refreshed:');
    debugPrint('[SECURITY CONTROLLER]   - isPinEnabled: ${isPinEnabled.value}');
    debugPrint(
        '[SECURITY CONTROLLER]   - isBiometricEnabled: ${isBiometricEnabled.value}');
    debugPrint(
        '[SECURITY CONTROLLER]   - isBiometricAvailable: ${isBiometricAvailable.value}');
    debugPrint('╔═══════════════════════════════════════════════════╗');
    debugPrint('║ [SECURITY CONTROLLER] ✅ Settings Refresh Complete║');
    debugPrint('╚═══════════════════════════════════════════════════╝\n');
  }

  // Session'ı sıfırla (uygulama kapatıldığında veya logout'ta)
  void resetAuthentication() {
    isAuthenticated.value = false;
    debugPrint('Authentication session reset');
  }
}
