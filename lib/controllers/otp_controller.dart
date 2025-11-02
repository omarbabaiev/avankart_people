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
    } else {
      email = '';
      loginToken = '';
      isFromRegister = false;
      isFromForgotPassword = false;
      print('[OTP CONTROLLER WARNING] Arguments not provided or invalid');
    }

    // Email ve token kontrolü
    if (email.isEmpty || loginToken.isEmpty) {
      print('[OTP CONTROLLER ERROR] Email or token is empty');
      SnackbarUtils.showErrorSnackbar('email_or_token_not_found'.tr);
      // Ana sayfaya yönlendir
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void submitOtp() async {
    // OTP submit butonuna tıklandığında haptic feedback
    VibrationUtil.lightVibrate();

    isLoading.value = true;
    try {
      final response = await _authService.submitOtp(
        email: email,
        otp: otpController.text.trim(),
        token: loginToken,
      );
      print('[OTP SUBMIT FULL RESPONSE] $response');

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

      if (isSuccessfulOtp || isAlreadyVerified) {
        // Başarılı OTP doğrulama - haptic feedback
        VibrationUtil.mediumVibrate();

        print('[OTP SUCCESS] Token received: ${newToken.substring(0, 20)}...');

        // Register'dan geliyorsa login'e yönlendir
        if (isFromRegister) {
          print('[REGISTER OTP SUCCESS] Navigating to login');
          SnackbarUtils.showSuccessSnackbar(
              'registration_completed_login_required'.tr);
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        // Forgot password'dan geliyorsa new password screen'e yönlendir
        if (isFromForgotPassword) {
          print(
              '[FORGOT PASSWORD OTP SUCCESS] Navigating to new password with original token');
          print('[FORGOT PASSWORD] Using original token: $forgotPasswordToken');
          Get.offNamed(AppRoutes.newPassword, arguments: {
            'email': email,
            'token':
                forgotPasswordToken, // OTP'den alınan değil, orijinal forgot password token'ı
          });
          return;
        }

        // Login'den geliyorsa token'ı kaydet ve home'a yönlendir
        print('[LOGIN OTP SUCCESS] Saving token and calling home');
        await _saveTokenAndProceed(newToken, rememberMe);
      } else {
        // OTP doğrulama hatası - haptic feedback
        VibrationUtil.heavyVibrate();
        SnackbarUtils.showErrorSnackbar('token_could_not_be_retrieved'.tr);
      }
    } catch (e) {
      // OTP submit hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      print('[OTP ERROR] $e');
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
      print('[TOKEN SAVED FOR HOME CALL] ${token.substring(0, 20)}...');
      print('[TOKEN SAVED] Full token length: ${token.length}');

      // Token'ın gerçekten kaydedilip kaydedilmediğini kontrol et
      final savedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
      print(
          '[TOKEN VERIFICATION] Saved token: ${savedToken?.substring(0, 20)}...');
      print('[TOKEN VERIFICATION] Token matches: ${savedToken == token}');

      // Eğer token kaydedilemediyse hata ver
      if (savedToken != token) {
        print('[TOKEN ERROR] Token could not be saved properly!');
        SnackbarUtils.showErrorSnackbar('token_save_error'.tr);
        return;
      }

      // Remember me durumunu GetStorage ile ayarla
      if (rememberMe) {
        GetStorage().write('rememberMe', true);
        print('[REMEMBER ME SAVED] true');
      } else {
        GetStorage().write('rememberMe', false);
        print('[REMEMBER ME SAVED] false');
      }

      // Token storage işleminin tamamlanması için bekleme
      await Future.delayed(const Duration(milliseconds: 200));

      // Token'ın gerçekten kaydedildiğini tekrar kontrol et
      final finalToken = await _storage.read(key: SecureStorageConfig.tokenKey);
      print('[FINAL TOKEN CHECK] Token: ${finalToken?.substring(0, 20)}...');
      print('[FINAL TOKEN CHECK] Matches: ${finalToken == token}');
      print('[FINAL TOKEN CHECK] Token length: ${finalToken?.length}');

      // Home endpoint'ini çağır - storage'dan token okunacak
      print('[CALLING HOME ENDPOINT]');
      final homeResponse = await _authService.home();
      print('[HOME RESPONSE] success: ${homeResponse?.success}');

      if (homeResponse?.success == true) {
        // Başarılı giriş - login controller'daki password'u temizle
        if (Get.isRegistered<LoginController>()) {
          Get.find<LoginController>().passwordController.clear();
        }

        // Home controller'ı tamamen temizle ve yeniden oluştur
        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>();
          print('[OTP] Deleted existing HomeController');
        }

        // Yeni HomeController oluştur ve selectedIndex'i 0'a set et
        final homeController = Get.put(HomeController(), permanent: true);
        print(
            '[OTP] Created new HomeController with selectedIndex: ${homeController.selectedIndex}');

        // Home'a yönlendir
        print('[HOME SUCCESS] Navigating to home');
        Get.offAllNamed(AppRoutes.main);
      } else {
        print('[HOME FAILED] success is not true');
        SnackbarUtils.showErrorSnackbar('main_page_could_not_load'.tr);
      }
    } catch (homeError) {
      print('[HOME ERROR] $homeError');
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

      print('[RESEND OTP ERROR] $e');
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
