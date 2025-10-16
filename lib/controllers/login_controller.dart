import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/auth_utils.dart';
import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';
import '../routes/app_routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controllers/home_controller.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final forgotPasswordLoading = false.obs;

  // New password screen için
  String email = '';
  String token = '';

  void login() async {
    // Login butonuna tıklandığında haptic feedback
    VibrationUtil.lightVibrate();

    isLoading.value = true;
    try {
      final LoginResponse response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      DebugLogger.controllerAction('LoginController', 'login', data: {
        'requiresOtp': response.requiresOtp,
        'token': response.token.substring(0, 20) + '...',
      });

      if (response.requiresOtp) {
        // OTP gerekli - token'ı storage'a kaydet, password'u temizle ve OTP ekranına yönlendir
        DebugLogger.info(LogCategory.controller,
            'OTP required, saving token and navigating to OTP screen');

        // Token'ı storage'a kaydet
        await _storage.write(
            key: SecureStorageConfig.tokenKey, value: response.token);
        print(
            '[LOGIN TOKEN SAVED FOR OTP] ${response.token.substring(0, 20)}...');

        passwordController.clear();
        Get.toNamed(AppRoutes.otp, arguments: {
          'email': emailController.text.trim(),
          'token': response.token,
          'rememberMe': rememberMe.value,
        });
      } else {
        // OTP gerekmiyor - direkt token'ı kaydet ve home'a yönlendir
        DebugLogger.info(LogCategory.controller,
            'OTP not required, proceeding directly to home');

        // Token'ı kaydet
        await _saveTokenAndProceed(response.token);
      }
    } catch (e) {
      // Login hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      DebugLogger.controllerError('LoginController', 'login', e);
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Token'ı kaydet ve home endpoint'ini çağır
  Future<void> _saveTokenAndProceed(String token) async {
    try {
      // Token'ı kaydet
      await _storage.write(key: SecureStorageConfig.tokenKey, value: token);

      // Remember me durumunu GetStorage ile ayarla
      if (rememberMe.value) {
        GetStorage().write('rememberMe', true);
        print('[TOKEN SAVED] With remember me: true');
      } else {
        GetStorage().write('rememberMe', false);
        print('[TOKEN SAVED] Without remember me');
      }

      // Token'ın gerçekten kaydedildiğini kontrol et
      final savedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
      if (savedToken != token) {
        print('[TOKEN ERROR] Token could not be saved properly!');
        SnackbarUtils.showErrorSnackbar('token_save_error'.tr);
        return;
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

      // Check if logout is required (status 2) - UserModel'den status kontrol et
      if (homeResponse != null &&
          homeResponse.user != null &&
          homeResponse.user!.status == 2) {
        print(
            '[LOGIN CONTROLLER] Status 2 detected in user model, force logging out user');
        await AuthUtils.forceLogout();
        return;
      }

      if (homeResponse?.success == true) {
        // Başarılı giriş - haptic feedback
        VibrationUtil.mediumVibrate();

        // Başarılı giriş - password'u temizle
        passwordController.clear();

        // Home controller'ı tamamen temizle ve yeniden oluştur
        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>();
          print('[LOGIN] Deleted existing HomeController');
        }

        // Yeni HomeController oluştur ve selectedIndex'i 0'a set et
        final homeController = Get.put(HomeController(), permanent: true);
        print(
            '[LOGIN] Created new HomeController with selectedIndex: ${homeController.selectedIndex}');

        // Verileri yükle
        await homeController.refreshUserData();

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

  /// New password screen için initialization
  void initializeNewPassword(String userEmail, String resetToken) {
    email = userEmail;
    token = resetToken;
  }

  /// Yeni şifre belirleme
  Future<void> submitNewPassword() async {
    // Şifre güncelleme butonuna tıklandığında haptic feedback
    VibrationUtil.lightVibrate();

    isLoading.value = true;
    try {
      // Yeni şifre belirleme API çağrısı
      final response = await _authService.submitNewPassword(
        token: token,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (response['token'] != null &&
          (response['success'] == true ||
              response['message'] == 'Password updated')) {
        print('[NEW PASSWORD SUCCESS] Password updated successfully');

        // Yeni token'ı kaydet
        final newToken = response['token'];
        await _authService.saveToken(newToken);
        print('[NEW PASSWORD] New token saved: $newToken');

        // Şifre güncellendiği için güvenlik nedeniyle login screen'e yönlendir
        print(
            '[NEW PASSWORD] Password updated, redirecting to login for security');

        // Token'ı temizle çünkü yeni login gerekli
        await _storage.delete(key: SecureStorageConfig.tokenKey);
        GetStorage().remove('rememberMe');
        print('[NEW PASSWORD] Tokens cleared for fresh login');

        // Başarılı şifre güncelleme - haptic feedback
        VibrationUtil.mediumVibrate();

        // Success mesajını göster ve ardından navigate et
        SnackbarUtils.showSuccessSnackbar('password_updated_successfully'.tr);

        // Kısa bir delay sonra navigate et ki snackbar görünsün
        await Future.delayed(const Duration(milliseconds: 1500));

        // Tüm controller'ları temizle ve login screen'e git
        Get.deleteAll();
        Get.offAllNamed(AppRoutes.login);
      } else {
        print('[NEW PASSWORD ERROR] ${response['message']}');
        final errorMessage =
            ApiResponseParser.parseApiMessage(response['message']);
        SnackbarUtils.showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      // Şifre güncelleme hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> forgotPassword({required String email}) async {
    forgotPasswordLoading.value = true;
    try {
      final response = await _authService.forgotPassword(email: email);
      return response;
    } catch (e) {
      rethrow;
    } finally {
      forgotPasswordLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Controllers'ı güvenli şekilde dispose et
    try {
      emailController.dispose();
      passwordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    } catch (e) {
      print('[LOGIN CONTROLLER] Error disposing controllers: $e');
    }
    super.onClose();
  }
}
