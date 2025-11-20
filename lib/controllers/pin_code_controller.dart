import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:avankart_people/controllers/security_controller.dart';
import 'package:avankart_people/controllers/splash_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'dart:io';
import 'package:avankart_people/services/pin_service.dart';

class PinCodeController extends GetxController {
  final RxString pin = ''.obs;
  final RxBool isConfirmScreen = false.obs;
  final RxString firstPin = ''.obs;
  final RxBool shouldShake = false.obs;
  final RxBool isEnterMode = false.obs; // PIN giriş modu için
  final RxBool verifyOnly = false.obs; // Sadece doğrulama modu
  final RxBool forDisable = false.obs; // Disable işlemi için
  final RxBool isForBiometric = false.obs; // Biometric için PIN setup
  final RxString platform = ''.obs; // Platform bilgisi (ios/android)
  final int pinLength = 4;
  final RxBool isLoading = false.obs; // Ağ istəkləri üçün overlay loading

  void addDigit(String digit) {
    // Her rakam girişinde haptic feedback
    VibrationUtil.selectionVibrate();

    if (pin.value.length < pinLength) {
      pin.value = pin.value + digit;

      // PIN kod tamamlandıysa
      if (pin.value.length == pinLength) {
        if (isEnterMode.value) {
          // PIN giriş modunda - doğrula
          validateEnteredPin();
        } else if (!isConfirmScreen.value) {
          // Birinci ekranda PIN kod tamamlandı, ikinci ekrana geç
          firstPin.value = pin.value;
          pin.value = '';
          isConfirmScreen.value = true;
        } else {
          // İkinci ekranda PIN kod tamamlandı, doğrula
          validatePin();
        }
      }
    }
  }

  void removeLastDigit() {
    // Silme işleminde haptic feedback
    VibrationUtil.lightVibrate();

    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  void validatePin() {
    if (pin.value == firstPin.value) {
      // PIN kodlar eşleşiyor - başarılı haptic feedback
      VibrationUtil.mediumVibrate();

      // PIN kodlar eşleşiyor
      // Kaydetme ve geri dönüş işlemleri savePin içinde yönetilir
      savePin();
    } else {
      // PIN kodlar eşleşmiyor - hata haptic feedback
      VibrationUtil.heavyVibrate();

      // PIN kodlar eşleşmiyor, shake animasyonu başlat
      shouldShake.value = true;
      Future.delayed(Duration(milliseconds: 500), () {
        shouldShake.value = false;
      });

      // PIN kodları sıfırla ve ilk ekrana dön
      resetPin();
    }
  }

  // PIN giriş modunda doğrulama
  void validateEnteredPin() async {
    final SecurityController securityController =
        Get.find<SecurityController>();
    isLoading.value = true;
    bool isValid = false;
    try {
      isValid = await securityController.authenticateWithPin(pin.value);
    } finally {
      isLoading.value = false;
    }

    if (isValid) {
      // PIN doğrulama başarılı - haptic feedback
      VibrationUtil.mediumVibrate();

      if (verifyOnly.value) {
        // Biyometrik enable/doğrulama veya disable işlemi için
        if (forDisable.value) {
          // Disable işlemi için direkt geri dön
          Get.back(result: true);
        } else {
          // Biyometrik enable/doğrulama için dialog göster
          await Get.dialog(
            Dialog(
              backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'pin_code_verified'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(Get.context!).colorScheme.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppTheme.primaryButtonStyle(),
                        onPressed: () {
                          Get.back();
                          Get.back(result: true);
                        },
                        child: Text('ok'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        }
      } else {
        // Uygulama açılışındaki PIN girişi - splash işlemlerini yap
        await _performSplashOperationsAndNavigate();
      }
    } else {
      // Yanlış PIN - hata haptic feedback
      VibrationUtil.heavyVibrate();

      // Yanlış PIN, shake animasyonu başlat
      shouldShake.value = true;
      Future.delayed(Duration(milliseconds: 500), () {
        shouldShake.value = false;
      });

      // PIN kodunu sıfırla
      pin.value = '';
    }
  }

  void resetPin() {
    pin.value = '';
    firstPin.value = '';
    isConfirmScreen.value = false;
    isEnterMode.value = false;
    isForBiometric.value = false;
    platform.value = '';
  }

  Future<void> savePin() async {
    try {
      // PIN kaydetme başarılı - haptic feedback
      VibrationUtil.mediumVibrate();
      isLoading.value = true;

      // Eğer PIN reset token ile geldiysek, backend'de reset et
      final args = Get.arguments;
      final String? pinResetToken =
          (args is Map) ? args['pinResetToken'] as String? : null;
      if (pinResetToken != null && pinResetToken.isNotEmpty) {
        final pinService = PinService();
        final ok = await pinService.changePinWithToken(
          newPin: pin.value,
          token: pinResetToken,
        );
        if (ok) {
          SnackbarUtils.showSuccessSnackbar('pin_code_saved_successfully'.tr);
          // Başarılı PIN reset → ana akışa direkt geç
          final SecurityController sec = Get.find<SecurityController>();
          await sec.refreshSettings();
          sec.isAuthenticated.value = true;
          Get.offAllNamed(AppRoutes.main);
          return;
        } else {
          SnackbarUtils.showErrorSnackbar('pin_code_save_error'.tr);
          return;
        }
      } else {
        final SecurityController sec = Get.find<SecurityController>();
        await sec.savePinCode(pin.value);
        // Security Controller'ın ayarlarını yenile
        await sec.refreshSettings();
        // Kullanıcıyı mevcut oturum için doğrulanmış kabul et
        sec.isAuthenticated.value = true;
      }

      // Başarı dialogu göster ve onayda geri dön
      await Get.dialog(
        Dialog(
          backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Projede bir Success widget'i varsa onu kullan
                // Örneğin: SuccessIcon() veya SuccessCheckmark() gibi bir widget varsa onu ekle
                // Eğer Success widget'i yoksa, geçici olarak bir Icon ekleyelim:
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _getSuccessMessage(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.onBackground,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppTheme.primaryButtonStyle(),
                    onPressed: () {
                      // Önce dialogu kapat ve geri dön, ardından bir sonraki frame'de snackbar göster
                      Get.back(); // dialog kapat
                      Get.back(result: true); // settings'e dön
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        SnackbarUtils.showSuccessSnackbar(
                            'pin_code_saved_successfully'.tr);
                      });
                    },
                    child: Text(
                      'ok'.tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      // PIN kaydetme hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      SnackbarUtils.showErrorSnackbar(
        'pin_code_save_error'.tr,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // PIN giriş modunu başlat
  void startEnterMode() {
    isEnterMode.value = true;
    pin.value = '';
    isConfirmScreen.value = false;
    firstPin.value = '';
  }

  // Dışarıdan doğrulama modu set et
  void setVerifyOnly(bool value) {
    verifyOnly.value = value;
  }

  // Disable işlemi için set et
  void setForDisable(bool value) {
    forDisable.value = value;
  }

  // Biometric için PIN setup modu set et
  void setForBiometric(bool value, String platformValue) {
    isForBiometric.value = value;
    platform.value = platformValue;
  }

  // PIN ayarlama modunu başlat
  void startSetupMode() {
    isEnterMode.value = false;
    pin.value = '';
    isConfirmScreen.value = false;
    firstPin.value = '';
    isForBiometric.value = false;
    platform.value = '';
  }

  /// PIN kod doğru girildikten sonra splash işlemlerini yap ve main'e git
  Future<void> _performSplashOperationsAndNavigate() async {
    try {
      debugPrint('[PIN CODE] PIN verified, performing splash operations...');

      // Loading overlay göster
      Get.dialog(
        Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator(radius: 14)
              : const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
        ),
        barrierDismissible: false,
      );

      // SplashController'ı başlat ve splash işlemlerini yap
      final splashController = Get.put(SplashController());

      // Splash işlemlerini yap (home endpoint çağrısı vs.)
      await splashController.performSplashOperations();

      // Loading overlay'i kapat
      Get.back();

      // Main screen'e git
      debugPrint('[PIN CODE] Splash operations completed, navigating to main');
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      debugPrint('[PIN CODE] Error during splash operations: $e');

      // Loading overlay'i kapat
      Get.back();

      // Hata durumunda da main'e git
      Get.offAllNamed(AppRoutes.main);
    }
  }

  String _getSuccessMessage() {
    if (isForBiometric.value) {
      if (platform.value == 'ios') {
        return 'face_id_enabled'.tr;
      } else {
        return 'fingerdebugPrint_enabled'.tr;
      }
    }
    return 'pin_code_saved_successfully'.tr;
  }
}
