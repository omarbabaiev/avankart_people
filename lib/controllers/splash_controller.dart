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

      // Token'ı storage'dan oku - tüm olası key'leri kontrol et
      var token = await _storage.read(key: SecureStorageConfig.tokenKey);

      // Eğer yeni key'de token yoksa, tüm olası key'leri kontrol et
      if (token == null || token.isEmpty) {
        // Eski key'leri kontrol et
        final oldToken = await _storage.read(key: 'token');
        final authToken = await _storage.read(key: 'auth_token');
        final userToken = await _storage.read(key: 'user_token');

        if (oldToken != null && oldToken.isNotEmpty) {
          print('[SPLASH] Found token in old key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: oldToken);
          token = oldToken;
        } else if (authToken != null && authToken.isNotEmpty) {
          print('[SPLASH] Found token in auth_token key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: authToken);
          token = authToken;
        } else if (userToken != null && userToken.isNotEmpty) {
          print('[SPLASH] Found token in user_token key, migrating to new key');
          await _storage.write(
              key: SecureStorageConfig.tokenKey, value: userToken);
          token = userToken;
        } else {
          print('[SPLASH] No token found in any key');
        }
      }

      // Remember me'yi GetStorage'dan oku
      final rememberMe = GetStorage().read('rememberMe') ?? false;

      print('[SPLASH] Token check - token: ${token?.substring(0, 20)}...');
      print('[SPLASH] Token is null: ${token == null}');
      print('[SPLASH] Token is empty: ${token?.isEmpty}');
      print('[SPLASH] Remember me: $rememberMe');
      print('[SPLASH] Remember me is true: $rememberMe');

      // 4 saniye animasyon oynat, sonra dur
      await _playAnimationOnce();

      // Token varsa home request at (remember me kontrolü opsiyonel)
      if (token != null && token.isNotEmpty) {
        print('[SPLASH] Token found, calling home endpoint');
        try {
          final homeResponse = await _authService.home();
          print('[SPLASH] Home response success: ${homeResponse?.success}');

          if (homeResponse?.success == true) {
            print('[SPLASH] Home success, checking PIN code requirements');

            // Remember me true ise PIN kod kontrolü yap
            if (rememberMe == true) {
              print('[SPLASH] Remember me is true, checking PIN code');
              await _checkPinCodeAndNavigate();
            } else {
              print(
                  '[SPLASH] Remember me is false, navigating directly to main');
              Get.offAllNamed(AppRoutes.main);
            }
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
        // Token yoksa remember me'yi temizle ve login'e git (GÜVENLİK)
        if (rememberMe == true) {
          print(
              '[SPLASH] No token found but remember me is true, clearing remember me and navigating to login');
          // Remember me'yi temizle çünkü token yok - GÜVENLİK
          GetStorage().remove('rememberMe');
        } else {
          print(
              '[SPLASH] No token found and remember me is false, performing logout');
          // Remember me false ise logout işlemi yap
          await AuthUtils.logout();
          return; // logout zaten login'e yönlendiriyor
        }
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

  /// Animasyonu bir kez oynat ve 4 saniye sonra dur
  Future<void> _playAnimationOnce() async {
    try {
      print('[SPLASH] Starting animation...');

      // 4 saniye bekle (animasyon oynatılacak)
      await Future.delayed(const Duration(seconds: 4));

      // Animasyon tamamlandı olarak işaretle
      isAnimationCompleted.value = true;
      print('[SPLASH] Animation completed');
    } catch (e) {
      print('[SPLASH] Error during animation: $e');
      // Hata durumunda da animasyon tamamlandı olarak işaretle
      isAnimationCompleted.value = true;
    }
  }

  /// Splash işlemlerini yap (home endpoint çağrısı)
  Future<void> performSplashOperations() async {
    try {
      print('[SPLASH] Performing splash operations...');

      // Home endpoint'ini çağır
      final homeResponse = await _authService.home();
      print('[SPLASH] Home response success: ${homeResponse?.success}');

      if (homeResponse?.success != true) {
        print('[SPLASH] Home failed during splash operations');
        // Home başarısız olursa logout yap
        await AuthUtils.logout();
        return;
      }

      print('[SPLASH] Splash operations completed successfully');
    } catch (e) {
      print('[SPLASH] Error during splash operations: $e');
      // Hata durumunda logout yap
      await AuthUtils.logout();
    }
  }

  /// PIN kod kontrolü yap ve uygun ekrana yönlendir
  Future<void> _checkPinCodeAndNavigate() async {
    try {
      // SecurityController'ı başlat
      final securityController = Get.put(SecurityController());

      // PIN kod enabled mi kontrol et
      final isPinEnabled = await securityController.isPinEnabled.value;
      print('[SPLASH] PIN code enabled: $isPinEnabled');

      if (isPinEnabled) {
        print('[SPLASH] PIN code is enabled, navigating to PIN code screen');
        // PIN kod ekranına git
        Get.offAllNamed(AppRoutes.enterPinCode);
      } else {
        print('[SPLASH] PIN code is not enabled, navigating directly to main');
        // PIN kod yoksa direkt main'e git
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      print('[SPLASH] Error checking PIN code: $e');
      // Hata durumunda direkt main'e git
      Get.offAllNamed(AppRoutes.main);
    }
  }

  /// Debug: Tüm storage key'lerini kontrol et
  Future<void> _debugAllKeys() async {
    try {
      final allKeys = await _storage.readAll();
      print('[SPLASH DEBUG] All stored keys: ${allKeys.keys.toList()}');

      // Tüm key'lerin değerlerini kontrol et
      for (final key in allKeys.keys) {
        final value = allKeys[key];
        if (value != null && value.isNotEmpty) {
          if (value.length > 50) {
            print(
                '[SPLASH DEBUG] $key: ${value.substring(0, 20)}... (${value.length} chars)');
          } else {
            print('[SPLASH DEBUG] $key: $value');
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

      print('[SPLASH DEBUG] auth_token key: ${token?.substring(0, 20)}...');
      print('[SPLASH DEBUG] rememberMe (GetStorage): $rememberMe');
      print('[SPLASH DEBUG] old token key: ${oldToken?.substring(0, 20)}...');
      print(
          '[SPLASH DEBUG] auth_token key (direct): ${authToken?.substring(0, 20)}...');
      print('[SPLASH DEBUG] user_token key: ${userToken?.substring(0, 20)}...');
      print('[SPLASH DEBUG] old rememberMe key: $oldRememberMe');

      // Eğer readAll() boş ama read() token buluyorsa, bu Flutter Secure Storage bug'ı
      if (allKeys.isEmpty && token != null) {
        print(
            '[SPLASH DEBUG] ⚠️ Flutter Secure Storage bug detected! readAll() empty but read() finds token');
      }
    } catch (e) {
      print('[SPLASH DEBUG] Error reading keys: $e');
    }
  }
}
