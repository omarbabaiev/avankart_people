import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/api_response_parser.dart';
import '../utils/secure_storage_config.dart';
import '../utils/auth_utils.dart';
import 'login_controller.dart';
import 'security_controller.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;
  final AuthService _authService = AuthService();
  final isInitialized = false.obs;
  final isRetrying = false.obs;
  final showRetryButton = false.obs;
  final retryMessage = ''.obs;
  final isAnimationCompleted = false.obs; // Animasyon tamamlandı mı?
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
    if (isFirstLaunch == false) {
      debugPrint('[SPLASH] First launch detected, clearing SecureStorage...');
      await _storage.deleteAll();
      await _getStorage.write('isFirstLaunch', true);
      debugPrint('[SPLASH] isFirstLaunch set to true');
    } else {
      debugPrint('[SPLASH] Not first launch, skipping SecureStorage clear');
    }
  }

  Future<void> _checkAuth() async {
    try {
      // Debug: Tüm key'leri kontrol et
      await _debugAllKeys();

      // Token'ı storage'dan oku - tüm olası key'leri kontrol et
      var token = await _storage.read(key: SecureStorageConfig.tokenKey);

      // Eğer yeni key'de token yoksa, tüm olası key'leri kontrol et
      if (token == null || token.isEmpty) {
        // Eski key'leri kontrol et
        final oldToken = await _storage.read(key: 'token');
        final authToken = await _storage.read(key: 'auth_token');
        final userToken = await _storage.read(key: 'user_token');

        if (oldToken != null && oldToken.isNotEmpty) {
          debugPrint('[SPLASH] Found token in old key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: oldToken);
          token = oldToken;
        } else if (authToken != null && authToken.isNotEmpty) {
          debugPrint(
              '[SPLASH] Found token in auth_token key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: authToken);
          token = authToken;
        } else if (userToken != null && userToken.isNotEmpty) {
          debugPrint(
              '[SPLASH] Found token in user_token key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: userToken);
          token = userToken;
        } else {
          debugPrint('[SPLASH] No token found in any key');
        }
      }

      // Remember me'yi GetStorage'dan oku
      final rememberMe = GetStorage().read('rememberMe') ?? false;

      debugPrint('[SPLASH] Token check - token: ${token?.substring(0, 20)}...');
      debugPrint('[SPLASH] Token is null: ${token == null}');
      debugPrint('[SPLASH] Token is empty: ${token?.isEmpty}');
      debugPrint('[SPLASH] Remember me: $rememberMe');
      debugPrint('[SPLASH] Remember me is true: $rememberMe');

      // Token yoksa önce intro kontrolü yap
      if (token == null || token.isEmpty) {
        debugPrint('[SPLASH] No token found, checking intro first');
        await _checkIntroAndNavigate(rememberMe);
        return; // Intro kontrolünden sonra çık
      }

      // 4 saniye animasyon oynat, sonra dur
      await _playAnimationOnce();

      // Token varsa home request at (remember me kontrolü opsiyonel)
      if (token.isNotEmpty) {
        debugPrint('[SPLASH] Token found, calling home endpoint');
        try {
          final homeResponse = await _authService.home();
          debugPrint(
              '[SPLASH] Home response success: ${homeResponse?.success}');

          if (homeResponse?.success == true) {
            debugPrint('[SPLASH] Home success, checking PIN code requirements');

            // Remember me true ise PIN kod kontrolü yap
            if (rememberMe == true) {
              debugPrint('[SPLASH] Remember me is true, checking PIN code');
              await _checkPinCodeAndNavigate();
            } else {
              debugPrint(
                  '[SPLASH] Remember me is false, navigating directly to main');
              Get.offAllNamed(AppRoutes.main);
            }
          } else {
            debugPrint('[SPLASH] Home failed, navigating to login');
            // Token geçersiz, tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
            await _storage.deleteAll();
            debugPrint('[SPLASH] All storage cleared');
            _clearPasswordField();
            Get.offAllNamed(AppRoutes.login);
          }
        } catch (e) {
          debugPrint('[SPLASH] Home request error: $e');

          // Tüm hatalar için retry butonu göster
          debugPrint('[SPLASH] Showing retry button for error');
          showRetryButton.value = true;
          retryMessage.value = _extractErrorMessage(e);
        }
      }
    } catch (e) {
      debugPrint('[SPLASH] Error during auth check: $e');

      // Hata türünü kontrol et
      if (_isRetryableError(e)) {
        debugPrint('[SPLASH] Retryable error detected, showing retry button');
        showRetryButton.value = true;
        // Retry butonu göster, login'e gitme
      } else {
        debugPrint(
            '[SPLASH] Non-retryable error, checking intro and navigating');
        // Hata durumunda tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
        await _storage.deleteAll();
        debugPrint('[SPLASH] All storage cleared due to error');
        _clearPasswordField();
        // Hata durumunda da intro kontrolü yap
        await _checkIntroAndNavigate(false);
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
      debugPrint('[SPLASH] Retry failed: $e');
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

  /// Animasyonu bir kez oynat ve 4 saniye sonra dur
  Future<void> _playAnimationOnce() async {
    try {
      debugPrint('[SPLASH] Starting animation...');

      // 4 saniye bekle (animasyon oynatılacak)
      await Future.delayed(const Duration(seconds: 4));

      // Animasyon tamamlandı olarak işaretle
      isAnimationCompleted.value = true;
      debugPrint('[SPLASH] Animation completed');
    } catch (e) {
      debugPrint('[SPLASH] Error during animation: $e');
      // Hata durumunda da animasyon tamamlandı olarak işaretle
      isAnimationCompleted.value = true;
    }
  }

  /// Splash işlemlerini yap (home endpoint çağrısı)
  Future<void> performSplashOperations() async {
    try {
      debugPrint('[SPLASH] Performing splash operations...');

      // Home endpoint'ini çağır
      final homeResponse = await _authService.home();
      debugPrint('[SPLASH] Home response success: ${homeResponse?.success}');

      if (homeResponse?.success != true) {
        debugPrint('[SPLASH] Home failed during splash operations');
        // Home başarısız olursa force logout yap
        await AuthUtils.forceLogout();
        return;
      }

      debugPrint('[SPLASH] Splash operations completed successfully');
    } catch (e) {
      debugPrint('[SPLASH] Error during splash operations: $e');
      // Hata durumunda force logout yap
      await AuthUtils.forceLogout();
    }
  }

  /// PIN kod kontrolü yap ve uygun ekrana yönlendir
  Future<void> _checkPinCodeAndNavigate() async {
    try {
      // SecurityController'ı başlat
      final securityController = Get.put(SecurityController());

      // Ayarları yükle
      await securityController.refreshSettings();

      // PIN kod veya biometric enabled mi kontrol et
      final isPinEnabled = securityController.isPinEnabled.value;
      final isBiometricEnabled = securityController.isBiometricEnabled.value;
      final isBiometricAvailable =
          securityController.isBiometricAvailable.value;

      debugPrint('[SPLASH] Security status:');
      debugPrint('[SPLASH]   - PIN enabled: $isPinEnabled');
      debugPrint('[SPLASH]   - Biometric enabled: $isBiometricEnabled');
      debugPrint('[SPLASH]   - Biometric available: $isBiometricAvailable');

      if (isPinEnabled || isBiometricEnabled) {
        debugPrint('[SPLASH] Security enabled, navigating to PIN code screen');

        // PIN ekranına git (biometric otomatik olarak PIN ekranında gösterilecek)
        Get.offAllNamed(AppRoutes.enterPinCode);
      } else {
        debugPrint('[SPLASH] No security enabled, navigating directly to main');
        // PIN kod yoksa direkt main'e git
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      debugPrint('[SPLASH] Error checking PIN code: $e');
      // Hata durumunda direkt main'e git
      Get.offAllNamed(AppRoutes.main);
    }
  }

  /// Intro kontrolü yap ve uygun ekrana yönlendir
  Future<void> _checkIntroAndNavigate(bool rememberMe) async {
    try {
      // Intro görülmüş mü kontrol et
      final hasSeenIntro = _getStorage.read('hasSeenIntro') ?? false;
      debugPrint('[SPLASH] Has seen intro: $hasSeenIntro');

      if (!hasSeenIntro) {
        debugPrint('[SPLASH] First time user, navigating to intro');
        // İlk kez açılıyor, intro'ya git
        Get.offAllNamed(AppRoutes.intro);
      } else {
        debugPrint('[SPLASH] Returning user, navigating to login');
        // Daha önce intro görülmüş, login'e git
        if (rememberMe == true) {
          debugPrint(
              '[SPLASH] No token found but remember me is true, clearing remember me and navigating to login');
          // Remember me'yi temizle çünkü token yok - GÜVENLİK
          GetStorage().remove('rememberMe');
        } else {
          debugPrint(
              '[SPLASH] No token found and remember me is false, clearing data and navigating to login');
          // Remember me false ise sadece storage'ı temizle, logout API çağırma
          await AuthUtils.clearDataWhenRememberMeFalse();
        }
        _clearPasswordField();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('[SPLASH] Error checking intro: $e');
      // Hata durumunda login'e git
      _clearPasswordField();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Debug: Tüm storage key'lerini kontrol et
  Future<void> _debugAllKeys() async {
    try {
      final allKeys = await _storage.readAll();
      debugPrint('[SPLASH DEBUG] All stored keys: ${allKeys.keys.toList()}');

      // Tüm key'lerin değerlerini kontrol et
      for (final key in allKeys.keys) {
        final value = allKeys[key];
        if (value != null && value.isNotEmpty) {
          if (value.length > 50) {
            debugPrint(
                '[SPLASH DEBUG] $key: ${value.substring(0, 20)}... (${value.length} chars)');
          } else {
            debugPrint('[SPLASH DEBUG] $key: $value');
          }
        }
      }

      // Token key'lerini kontrol et
      final token = await _storage.read(key: SecureStorageConfig.tokenKey);
      final rememberMe = GetStorage().read('rememberMe');

      // Tüm olası token key'lerini kontrol et
      final oldToken = await _storage.read(key: 'token');
      final authToken = await _storage.read(key: 'auth_token');
      final userToken = await _storage.read(key: 'user_token');
      final oldRememberMe = await _storage.read(key: 'rememberMe');

      debugPrint(
          '[SPLASH DEBUG] auth_token key: ${token?.substring(0, 20)}...');
      debugPrint('[SPLASH DEBUG] rememberMe (GetStorage): $rememberMe');
      debugPrint(
          '[SPLASH DEBUG] old token key: ${oldToken?.substring(0, 20)}...');
      debugPrint(
          '[SPLASH DEBUG] auth_token key (direct): ${authToken?.substring(0, 20)}...');
      debugPrint(
          '[SPLASH DEBUG] user_token key: ${userToken?.substring(0, 20)}...');
      debugPrint('[SPLASH DEBUG] old rememberMe key: $oldRememberMe');

      // Eğer readAll() boş ama read() token buluyorsa, bu Flutter Secure Storage bug'ı
      if (allKeys.isEmpty && token != null) {
        debugPrint(
            '[SPLASH DEBUG] ⚠️ Flutter Secure Storage bug detected! readAll() empty but read() finds token');
      }
    } catch (e) {
      debugPrint('[SPLASH DEBUG] Error reading keys: $e');
    }
  }
}
