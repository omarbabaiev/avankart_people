import '../utils/snackbar_utils.dart';
import '../utils/api_response_parser.dart';
import '../utils/vibration_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/secure_storage_config.dart';
import 'login_controller.dart';
import 'home_controller.dart';
import '../services/pin_service.dart';

class OtpController extends GetxController {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  final otpController = TextEditingController();
  final isLoading = false.obs;
  final isResending = false.obs;

  String email = '';
  String loginToken = '';
  String forgotPasswordToken = ''; // Forgot password'dan alınan orijinal token
  bool isFromRegister = false;
  bool isFromForgotPassword = false;
  bool isPinReset = false;

  @override
  void onInit() {
    super.onInit();
    // Güvenli erişim - Get.arguments null olabilir
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      email = arguments['email'] ?? '';
      loginToken = arguments['token'] ?? '';
      forgotPasswordToken =
          arguments['forgotPasswordToken'] ?? arguments['token'] ?? '';
      isFromRegister = arguments['isRegister'] ?? false;
      isFromForgotPassword = arguments['isForgotPassword'] ?? false;
      isPinReset = arguments['isPinReset'] ?? false;
    } else {
      email = '';
      loginToken = '';
      isFromRegister = false;
      isFromForgotPassword = false;
      isPinReset = false;
      debugPrint('[OTP CONTROLLER WARNING] Arguments not provided or invalid');
    }

    // Email ve token kontrolü (PIN reset modunda gereksiz)
    if (!isPinReset) {
      if (email.isEmpty || loginToken.isEmpty) {
        debugPrint('[OTP CONTROLLER ERROR] Email or token is empty');
        SnackbarUtils.showErrorSnackbar('email_or_token_not_found'.tr);
        // Ana sayfaya yönlendir
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  void submitOtp() async {
    // OTP submit butonuna tıklandığında haptic feedback
    VibrationUtil.lightVibrate();

    isLoading.value = true;
    try {
      Map<String, dynamic> response;
      if (isPinReset) {
        // PIN reset OTP doğrulama ve token alma
        final pinService = PinService();
        response = await pinService.submitOtp(otp: otpController.text.trim());
      } else {
        response = await _authService.submitOtp(
          email: email,
          otp: otpController.text.trim(),
          token: loginToken,
        );
      }
      debugPrint('[OTP SUBMIT FULL RESPONSE] $response');

      // Yeni token response'dan alınır ve saklanır
      final newToken = response['token'];
      final success = response['success'];
      final message = response['message'];
      final rememberMe =
          Get.arguments != null && Get.arguments['rememberMe'] == true;

      // Token kontrolü
      if (newToken == null || newToken is! String) {
        SnackbarUtils.showErrorSnackbar('token_could_not_be_retrieved'.tr);
        return;
      }

      // Başarılı OTP doğrulaması kontrolü
      final isSuccessfulOtp =
          (success == true || message == 'ok' || message == 'OTP verified');
      final isAlreadyVerified =
          (message == null || message == 'OTP already verified');

      if (isPinReset) {
        // PIN reset OTP successful → set pin screen'e token ile git
        final pinResetToken = response['token'];
        if (pinResetToken is String && pinResetToken.isNotEmpty) {
          Get.offNamed(AppRoutes.setPinCode, arguments: {
            'allowBack': true,
            'pinResetToken': pinResetToken,
          });
          return;
        } else {
          SnackbarUtils.showErrorSnackbar('token_could_not_be_retrieved'.tr);
          return;
        }
      } else if (isSuccessfulOtp || isAlreadyVerified) {
        // Başarılı OTP doğrulama - haptic feedback
        VibrationUtil.mediumVibrate();

        debugPrint(
            '[OTP SUCCESS] Token received: ${newToken.substring(0, 20)}...');

        // Register'dan geliyorsa login'e yönlendir
        if (isFromRegister) {
          debugPrint('[REGISTER OTP SUCCESS] Navigating to login');
          SnackbarUtils.showSuccessSnackbar(
              'registration_completed_login_required'.tr);
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        // Forgot password'dan geliyorsa new password screen'e yönlendir
        if (isFromForgotPassword) {
          debugPrint(
              '[FORGOT PASSWORD OTP SUCCESS] Navigating to new password with OTP verified token');
          debugPrint(
              '[FORGOT PASSWORD] Using OTP verified token: ${newToken.substring(0, 20)}...');
          Get.offNamed(AppRoutes.newPassword, arguments: {
            'email': email,
            'token': newToken, // OTP doğrulamasından sonra alınan yeni token
          });
          return;
        }

        // Login'den geliyorsa token'ı kaydet ve home'a yönlendir
        debugPrint('[LOGIN OTP SUCCESS] Saving token and calling home');
        await _saveTokenAndProceed(newToken, rememberMe);
      } else {
        // OTP doğrulama hatası - haptic feedback
        VibrationUtil.heavyVibrate();
        SnackbarUtils.showErrorSnackbar('token_could_not_be_retrieved'.tr);
      }
    } catch (e) {
      // OTP submit hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      debugPrint('[OTP ERROR] $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Token'ı kaydet ve home endpoint'ini çağır
  Future<void> _saveTokenAndProceed(String token, bool rememberMe) async {
    try {
      // Token'ı kaydet ve işlemin tamamlanmasını bekle
      await _storage.write(key: SecureStorageConfig.tokenKey, value: token);
      debugPrint('[TOKEN SAVED FOR HOME CALL] ${token.substring(0, 20)}...');
      debugPrint('[TOKEN SAVED] Full token length: ${token.length}');

      // Token'ın gerçekten kaydedilip kaydedilmediğini kontrol et
      final savedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
      debugPrint(
          '[TOKEN VERIFICATION] Saved token: ${savedToken?.substring(0, 20)}...');
      debugPrint('[TOKEN VERIFICATION] Token matches: ${savedToken == token}');

      // Eğer token kaydedilemediyse hata ver
      if (savedToken != token) {
        debugPrint('[TOKEN ERROR] Token could not be saved properly!');
        SnackbarUtils.showErrorSnackbar('token_save_error'.tr);
        return;
      }

      // Remember me durumunu GetStorage ile ayarla
      if (rememberMe) {
        GetStorage().write('rememberMe', true);
        debugPrint('[REMEMBER ME SAVED] true');
      } else {
        GetStorage().write('rememberMe', false);
        debugPrint('[REMEMBER ME SAVED] false');
      }

      // Token storage işleminin tamamlanması için bekleme
      await Future.delayed(const Duration(milliseconds: 200));

      // Token'ın gerçekten kaydedildiğini tekrar kontrol et
      final finalToken = await _storage.read(key: SecureStorageConfig.tokenKey);
      debugPrint(
          '[FINAL TOKEN CHECK] Token: ${finalToken?.substring(0, 20)}...');
      debugPrint('[FINAL TOKEN CHECK] Matches: ${finalToken == token}');
      debugPrint('[FINAL TOKEN CHECK] Token length: ${finalToken?.length}');

      // Home endpoint'ini çağır - storage'dan token okunacak
      debugPrint('[CALLING HOME ENDPOINT]');
      final homeResponse = await _authService.home();
      debugPrint('[HOME RESPONSE] success: ${homeResponse?.success}');

      if (homeResponse?.success == true) {
        // Başarılı giriş - login controller'daki password'u temizle
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().passwordController.clear();
        }

        // Home controller'ı tamamen temizle ve yeniden oluştur
        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>();
          debugPrint('[OTP] Deleted existing HomeController');
        }

        // Yeni HomeController oluştur ve selectedIndex'i 0'a set et
        final homeController = Get.put(HomeController(), permanent: true);
        debugPrint(
            '[OTP] Created new HomeController with selectedIndex: ${homeController.selectedIndex}');

        // Home'a yönlendir
        debugPrint('[HOME SUCCESS] Navigating to home');
        Get.offAllNamed(AppRoutes.main);
      } else {
        debugPrint('[HOME FAILED] success is not true');
        SnackbarUtils.showErrorSnackbar('main_page_could_not_load'.tr);
      }
    } catch (homeError) {
      debugPrint('[HOME ERROR] $homeError');
      final errorMessage = ApiResponseParser.parseDioError(homeError);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    }
  }

  /// OTP'yi yeniden gönder
  /// Returns: true if successful, false otherwise
  Future<bool> resendOtp() async {
    // OTP yeniden gönderme butonuna tıklandığında haptic feedback
    VibrationUtil.lightVibrate();

    if (email.isEmpty || loginToken.isEmpty) {
      SnackbarUtils.showErrorSnackbar('email_or_token_not_found'.tr);
      return false;
    }

    isResending.value = true;
    try {
      final response = await _authService.resendOtp(
        email: email,
        token: loginToken,
      );

      final success = response['success'];
      final message = response['message'];

      // JSON-da "OTP resent successfully" və ya "OTP sent successfully" mesajı qayıdır
      if (success == true ||
          message == 'OTP sent successfully' ||
          message == 'OTP resent successfully' ||
          message == 'ok') {
        // Başarılı OTP yeniden gönderme - haptic feedback
        VibrationUtil.selectionVibrate();
        SnackbarUtils.showSuccessSnackbar('verification_code_resent'.tr);
        return true; // Success qaytar
      } else {
        // OTP yeniden gönderme hatası - haptic feedback
        VibrationUtil.heavyVibrate();
        SnackbarUtils.showErrorSnackbar(message ?? 'otp_resend_failed'.tr);
        return false; // Success deyil
      }
    } catch (e) {
      // OTP yeniden gönderme hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      debugPrint('[RESEND OTP ERROR] $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false; // Success deyil
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
