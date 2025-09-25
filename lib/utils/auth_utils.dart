import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'secure_storage_config.dart';

class AuthUtils {
  /// Logout the user and clear all data
  static Future<void> logout() async {
    try {
      final authService = AuthService();
      final storage = SecureStorageConfig.storage;
      final firebaseService = FirebaseService();

      // Call logout API
      await authService.logout();

      // Clear stored data - Tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
      print('[AUTH UTILS] Clearing all storage due to readAll() bug...');
      await storage.deleteAll(); // Tüm storage'ı temizle
      print('[AUTH UTILS] All storage cleared');

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
      final storage = SecureStorageConfig.storage;
      final firebaseService = FirebaseService();
      await storage.deleteAll(); // Tüm storage'ı temizle
      print('[AUTH UTILS] All storage cleared after error');

      await firebaseService.clearToken();
      Get.deleteAll();
      Get.offAllNamed('/login');
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
