import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/api_response_parser.dart';
import '../utils/secure_storage_config.dart';
import 'login_controller.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  final isInitialized = false.obs;
  final isRetrying = false.obs;
  final showRetryButton = false.obs;
  final retryMessage = ''.obs;
  final GetStorage _getStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _clearSecureStorageOnFirstLaunch();
    _checkAuth();
  }

  /// Uygulama ilk açılışında SecureStorage'ı temizle
  Future<void> _clearSecureStorageOnFirstLaunch() async {
    final isFirstLaunch = _getStorage.read('isFirstLaunch') ?? false;
    if (!isFirstLaunch) {
      print('[SPLASH] First launch detected, clearing SecureStorage...');
      await _storage.deleteAll();
      await _getStorage.write('isFirstLaunch', true);
    }
  }

  Future<void> _checkAuth() async {
    try {
      // Debug: Tüm key'leri kontrol et
      await _debugAllKeys();

      final token = await _storage.read(key: 'token');
      final rememberMe = await _storage.read(key: 'rememberMe');

      print('[SPLASH] Token check - token: ${token?.substring(0, 20)}...');
      print('[SPLASH] Remember me: $rememberMe');

      await Future.delayed(
          const Duration(seconds: 2)); // Lottie animasyonu için bekleme

      // Token varsa ve remember me true ise home request at
      if (token != null && token.isNotEmpty && rememberMe == 'true') {
        print('[SPLASH] Token found, calling home endpoint');
        try {
          final homeResponse = await _authService.home();
          print('[SPLASH] Home response success: ${homeResponse?.success}');

          if (homeResponse?.success == true) {
            print('[SPLASH] Home success, navigating to main');
            Get.offAllNamed(AppRoutes.main);
          } else {
            print('[SPLASH] Home failed, navigating to login');
            // Token geçersiz, tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
            await _storage.deleteAll();
            print('[SPLASH] All storage cleared');
            _clearPasswordField();
            Get.offAllNamed(AppRoutes.login);
          }
        } catch (e) {
          print('[SPLASH] Home request error: $e');

          // Tüm hatalar için retry butonu göster
          print('[SPLASH] Showing retry button for error');
          showRetryButton.value = true;
          retryMessage.value = _extractErrorMessage(e);
        }
      } else {
        print('[SPLASH] No token or remember me false, navigating to login');
        // Token yoksa veya remember me false ise login'e git
        _clearPasswordField();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print('[SPLASH] Error during auth check: $e');

      // Hata türünü kontrol et
      if (_isRetryableError(e)) {
        print('[SPLASH] Retryable error detected, showing retry button');
        showRetryButton.value = true;
        // Retry butonu göster, login'e gitme
      } else {
        print('[SPLASH] Non-retryable error, navigating to login');
        // Hata durumunda tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
        await _storage.deleteAll();
        print('[SPLASH] All storage cleared due to error');
        _clearPasswordField();
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      isInitialized.value = true;
    }
  }

  /// Retry butonuna basıldığında çağrılır
  Future<void> retryAuth() async {
    if (isRetrying.value) return; // Çift tıklamayı önle

    isRetrying.value = true;
    showRetryButton.value = false;
    retryMessage.value = '';

    try {
      await _checkAuth();
    } catch (e) {
      print('[SPLASH] Retry failed: $e');
      showRetryButton.value = true;
      retryMessage.value = _extractErrorMessage(e);
    } finally {
      isRetrying.value = false;
    }
  }

  /// Hatanın retry edilebilir olup olmadığını kontrol et
  bool _isRetryableError(dynamic error) {
    String errorMessage = '';

    if (error is AuthException) {
      errorMessage = error.message;
    } else if (error is String) {
      errorMessage = error;
    } else {
      errorMessage = error.toString();
    }

    return errorMessage.contains('network_error_retry') ||
        errorMessage.contains('retry_available');
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(dynamic error) {
    return ApiResponseParser.parseDioError(error);
  }

  /// Login controller'daki password field'ını temizle
  void _clearPasswordField() {
    if (Get.isRegistered<LoginController>()) {
      Get.find<LoginController>().passwordController.clear();
    }
  }

  /// Debug: Tüm storage key'lerini kontrol et
  Future<void> _debugAllKeys() async {
    try {
      final allKeys = await _storage.readAll();
      print('[SPLASH DEBUG] All stored keys: ${allKeys.keys.toList()}');

      // Token key'lerini ayrı ayrı kontrol et
      final token1 = await _storage.read(key: 'token');
      final token2 = await _storage.read(key: SecureStorageConfig.tokenKey);
      final rememberMe1 = await _storage.read(key: 'rememberMe');
      final rememberMe2 =
          await _storage.read(key: SecureStorageConfig.rememberMeKey);

      print('[SPLASH DEBUG] token key: ${token1?.substring(0, 20)}...');
      print('[SPLASH DEBUG] auth_token key: ${token2?.substring(0, 20)}...');
      print('[SPLASH DEBUG] rememberMe key: $rememberMe1');
      print('[SPLASH DEBUG] remember_me key: $rememberMe2');

      // Eğer readAll() boş ama read() token buluyorsa, bu Flutter Secure Storage bug'ı
      if (allKeys.isEmpty && token1 != null) {
        print(
            '[SPLASH DEBUG] ⚠️ Flutter Secure Storage bug detected! readAll() empty but read() finds token');
      }
    } catch (e) {
      print('[SPLASH DEBUG] Error reading keys: $e');
    }
  }
}
