import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../controllers/security_controller.dart';
import 'secure_storage_config.dart';
import 'snackbar_utils.dart';

class AuthUtils {
  /// Logout the user and clear all data (manual logout with API call)
  static Future<void> logout() async {
    try {
      final authService = AuthService();
      final firebaseService = FirebaseService();

      // Call logout API
      final response = await authService.logout();

      // Response kontrolü - "Logged out" mesajı var mı?
      if (response == null || response['message'] != 'Logged out') {
        print('[AUTH UTILS] Logout failed - invalid response: $response');
        // Hata mesajını göster
        final errorMessage = response?['message'] ?? 'auth.logout_error'.tr;
        _showLogoutError(errorMessage);
        return; // İşlemleri durdur
      }

      print('[AUTH UTILS] Logout successful, clearing all data...');

      // Clear all stored data
      await _clearAllStorageData();

      // Clear Firebase token
      await firebaseService.clearToken();

      // Reset SecurityController observable values and clear PIN/biometric settings
      if (Get.isRegistered<SecurityController>()) {
        final securityController = Get.find<SecurityController>();
        securityController.isPinEnabled.value = false;
        securityController.isBiometricEnabled.value = false;
        securityController.resetAuthentication();

        // PIN kod ve biometric ayarlarını SecureStorage'dan temizle
        await _clearSecuritySettings();

        print('[AUTH UTILS] SecurityController settings reset and cleared');
      }

      // Clear all controllers
      Get.deleteAll();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('[AUTH UTILS] Logout error: $e');
      // API hatası - kullanıcıya göster
      _showLogoutError('auth.logout_error'.tr);
    }
  }

  /// Force logout without API call (for invalid tokens, status 2, etc.)
  static Future<void> forceLogout() async {
    try {
      print(
          '[AUTH UTILS] Force logout - clearing all data without API call...');

      // Clear all stored data
      await _clearAllStorageData();

      // Clear Firebase token
      final firebaseService = FirebaseService();
      await firebaseService.clearToken();

      // Reset SecurityController observable values and clear PIN/biometric settings
      if (Get.isRegistered<SecurityController>()) {
        final securityController = Get.find<SecurityController>();
        securityController.isPinEnabled.value = false;
        securityController.isBiometricEnabled.value = false;
        securityController.resetAuthentication();

        // PIN kod ve biometric ayarlarını SecureStorage'dan temizle
        await _clearSecuritySettings();

        print('[AUTH UTILS] SecurityController settings reset and cleared');
      }

      // Clear all controllers
      Get.deleteAll();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('[AUTH UTILS] Force logout error: $e');
      // Hata olsa bile login'e yönlendir
      Get.offAllNamed('/login');
    }
  }

  /// Clear security settings from SecureStorage
  static Future<void> _clearSecuritySettings() async {
    try {
      final storage = SecureStorageConfig.storage;

      // PIN kod ve biometric ayarlarını temizle
      await storage.delete(key: SecureStorageConfig.pinCodeKey);
      await storage.delete(key: SecureStorageConfig.biometricEnabledKey);

      print('[AUTH UTILS] Security settings cleared from SecureStorage');
    } catch (e) {
      print('[AUTH UTILS] Error clearing security settings: $e');
      // Hata olsa bile devam et
    }
  }

  /// Clear all storage data (SecureStorage + GetStorage)
  static Future<void> _clearAllStorageData() async {
    try {
      final storage = SecureStorageConfig.storage;

      // Clear SecureStorage - Tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
      print('[AUTH UTILS] Clearing SecureStorage...');
      await storage.deleteAll();
      print('[AUTH UTILS] SecureStorage cleared');

      // Clear GetStorage
      print('[AUTH UTILS] Clearing GetStorage...');
      await GetStorage().erase();
      print('[AUTH UTILS] GetStorage cleared');

      // isFirstLaunch'u tekrar true yap (artık ilk açılış değil anlamında)
      print('[AUTH UTILS] Setting isFirstLaunch to true after logout');
      await GetStorage().write('isFirstLaunch', true);

      print('[AUTH UTILS] All storage data cleared successfully');
    } catch (e) {
      print('[AUTH UTILS] Error clearing storage: $e');
      // Even if clearing fails, continue with logout
    }
  }

  /// Clear all data when remember me is false and token is not found
  static Future<void> clearDataWhenRememberMeFalse() async {
    try {
      print(
          '[AUTH UTILS] Remember me is false and token not found, clearing all data...');

      // Clear all stored data
      await _clearAllStorageData();

      // Clear all controllers
      Get.deleteAll();

      print('[AUTH UTILS] All data cleared due to remember me false');
    } catch (e) {
      print('[AUTH UTILS] Error clearing data when remember me false: $e');
    }
  }

  /// Check if API response indicates logout is required (status 2)
  static bool shouldLogout(dynamic responseData) {
    if (responseData == null) return false;

    // Check if response is a Map and contains status field
    if (responseData is Map<String, dynamic>) {
      final status = responseData['status'];
      return status == 2 || status == '2';
    }

    return false;
  }

  /// Show logout error snackbar
  static void _showLogoutError(String message) {
    SnackbarUtils.showErrorSnackbar(message);
  }
}
