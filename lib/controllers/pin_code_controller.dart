import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:avankart_people/controllers/security_controller.dart';
import 'package:avankart_people/controllers/splash_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';

class PinCodeController extends GetxController {
  final RxString pin = ''.obs;
  final RxBool isConfirmScreen = false.obs;
  final RxString firstPin = ''.obs;
  final RxBool shouldShake = false.obs;
  final RxBool isEnterMode = false.obs; // PIN giriş modu için
  final RxBool verifyOnly = false.obs; // Sadece doğrulama modu
  final int pinLength = 4;

  void addDigit(String digit) {
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
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  void validatePin() {
    if (pin.value == firstPin.value) {
      // PIN kodlar eşleşiyor
      // Kaydetme ve geri dönüş işlemleri savePin içinde yönetilir
      savePin();
    } else {
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
    final bool isValid =
        await securityController.authenticateWithPin(pin.value);

    if (isValid) {
      if (verifyOnly.value) {
        // Biyometrik enable/doğrulama için
        await Get.dialog(
          Dialog(
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
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
      } else {
        // Uygulama açılışındaki PIN girişi - splash işlemlerini yap
        await _performSplashOperationsAndNavigate();
      }
    } else {
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
  }

  Future<void> savePin() async {
    try {
      final SecurityController securityController =
          Get.find<SecurityController>();
      await securityController.savePinCode(pin.value);

      // Security Controller'ın ayarlarını yenile
      await securityController.refreshSettings();

      // Kullanıcıyı mevcut oturum için doğrulanmış kabul et
      securityController.isAuthenticated.value = true;

      // Başarı dialogu göster ve onayda geri dön
      await Get.dialog(
        Dialog(
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
                  'pin_code_saved_successfully'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      Get.back(); // dialog kapat
                      Get.back(result: true); // settings'e dön
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
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(
        'pin_code_save_error'.tr,
      );
      rethrow;
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

  // PIN ayarlama modunu başlat
  void startSetupMode() {
    isEnterMode.value = false;
    pin.value = '';
    isConfirmScreen.value = false;
    firstPin.value = '';
  }

  /// PIN kod doğru girildikten sonra splash işlemlerini yap ve main'e git
  Future<void> _performSplashOperationsAndNavigate() async {
    try {
      print('[PIN CODE] PIN verified, performing splash operations...');

      // Loading overlay göster
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
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
      print('[PIN CODE] Splash operations completed, navigating to main');
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      print('[PIN CODE] Error during splash operations: $e');

      // Loading overlay'i kapat
      Get.back();

      // Hata durumunda da main'e git
      Get.offAllNamed(AppRoutes.main);
    }
  }
}
