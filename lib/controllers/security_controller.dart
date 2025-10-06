import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io';

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
      final String? pinEnabled =
          await _storage.read(key: SecureStorageConfig.pinCodeKey);
      final String? biometricEnabled =
          await _storage.read(key: SecureStorageConfig.biometricEnabledKey);

      isPinEnabled.value = pinEnabled != null && pinEnabled.isNotEmpty;
      isBiometricEnabled.value = biometricEnabled == 'true';
    } catch (e) {
      print('Error loading security settings: $e');
    }
  }

  // Biyometrik authentication mevcutluğunu kontrol et
  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      // Platform'a göre uygun biyometrik türünü kontrol et
      bool hasRequiredBiometric = false;
      if (Platform.isIOS) {
        // iOS'da Face ID veya Touch ID kontrolü
        hasRequiredBiometric =
            availableBiometrics.contains(BiometricType.face) ||
                availableBiometrics.contains(BiometricType.fingerprint);
      } else if (Platform.isAndroid) {
        // Android'de parmak izi kontrolü
        hasRequiredBiometric =
            availableBiometrics.contains(BiometricType.fingerprint);
      }

      isBiometricAvailable.value = isAvailable && hasRequiredBiometric;
    } catch (e) {
      print('Error checking biometric availability: $e');
      isBiometricAvailable.value = false;
    }
  }

  // PIN kod aktif/pasif et
  Future<void> togglePinCode() async {
    try {
      if (isPinEnabled.value) {
        // PIN kodunu devre dışı bırak
        await _storage.delete(key: SecureStorageConfig.pinCodeKey);
        isPinEnabled.value = false;

        // PIN kod devre dışıysa biyometrik de devre dışı bırak
        if (isBiometricEnabled.value) {
          await toggleBiometric(false);
        }

        SnackbarUtils.showSuccessSnackbar('pin_code_disabled'.tr);
      } else {
        // PIN kod ayarlama ekranına git (settings'den geldiği için geri gidebilsin)
        Get.toNamed(AppRoutes.setPinCode, arguments: {'allowBack': true});
      }
    } catch (e) {
      print('Error toggling PIN code: $e');
      SnackbarUtils.showErrorSnackbar('pin_code_error'.tr);
    }
  }

  // Biyometrik authentication aktif/pasif et
  Future<void> toggleBiometric([bool? value]) async {
    try {
      if (!isPinEnabled.value) {
        SnackbarUtils.showErrorSnackbar('pin_code_warning'.tr);

        return;
      }

      final bool newValue = value ?? !isBiometricEnabled.value;

      if (newValue) {
        // Biyometrik authentication test et
        final bool didAuthenticate = await _authenticateWithBiometric();
        if (didAuthenticate) {
          await _storage.write(
              key: SecureStorageConfig.biometricEnabledKey, value: 'true');
          isBiometricEnabled.value = true;

          SnackbarUtils.showSuccessSnackbar(
              Platform.isIOS ? 'face_id_enabled'.tr : 'fingerprint_enabled'.tr);
        }
      } else {
        await _storage.delete(key: SecureStorageConfig.biometricEnabledKey);
        isBiometricEnabled.value = false;

        SnackbarUtils.showSuccessSnackbar(
            Platform.isIOS ? 'face_id_disabled'.tr : 'fingerprint_disabled'.tr);
      }
    } catch (e) {
      print('Error toggling biometric: $e');
      SnackbarUtils.showErrorSnackbar('biometric_error'.tr);
    }
  }

  // Biyometrik authentication ile doğrula
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
        // Android'de sadece parmak izi
        if (availableBiometrics.contains(BiometricType.fingerprint)) {
          allowedBiometrics = [BiometricType.fingerprint];
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
            : 'fingerprint_verify'.tr,
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
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // PIN kod ile doğrula
  Future<bool> authenticateWithPin(String pin) async {
    try {
      final String? savedPin =
          await _storage.read(key: SecureStorageConfig.pinCodeKey);
      final bool isValid = savedPin == pin;

      if (isValid) {
        // Authentication başarılı, session flag'i set et
        isAuthenticated.value = true;
      }

      return isValid;
    } catch (e) {
      print('PIN authentication error: $e');
      return false;
    }
  }

  // PIN kod kaydet
  Future<void> savePinCode(String pin) async {
    try {
      await _storage.write(key: SecureStorageConfig.pinCodeKey, value: pin);
      isPinEnabled.value = true;
      print('PIN kod kaydedildi, isPinEnabled: ${isPinEnabled.value}');
    } catch (e) {
      print('Error saving PIN code: $e');
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
    await _loadSecuritySettings();
    await _checkBiometricAvailability();
    print(
        'Settings refreshed - isPinEnabled: ${isPinEnabled.value}, isBiometricEnabled: ${isBiometricEnabled.value}');
  }

  // Session'ı sıfırla (uygulama kapatıldığında veya logout'ta)
  void resetAuthentication() {
    isAuthenticated.value = false;
    print('Authentication session reset');
  }
}
