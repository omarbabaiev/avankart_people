import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'secure_storage_config.dart';

class AuthUtils {
  /// Logout the user and clear all data
  static Future<void> logout() async {
    try {
      final authService = AuthService();
      final firebaseService = FirebaseService();

      // Call logout API
      await authService.logout();

      // Clear all stored data
      await _clearAllStorageData();

      // Clear Firebase token
      await firebaseService.clearToken();

      // Clear all controllers
      Get.deleteAll();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      print('[AUTH UTILS] Logout error: $e');
      // Even if logout API fails, clear local data and redirect
      print('[AUTH UTILS] Logout API failed, clearing all storage...');

      // Clear all stored data
      await _clearAllStorageData();

      final firebaseService = FirebaseService();
      await firebaseService.clearToken();
      Get.deleteAll();
      Get.offAllNamed('/login');
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
}
