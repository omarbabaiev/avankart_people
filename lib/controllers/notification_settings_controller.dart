import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import '../services/firebase_service.dart';
import '../services/notifications_service.dart';
import '../utils/api_response_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/snackbar_utils.dart';

class NotificationSettingsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationsService _notificationsService = NotificationsService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final isNotificationEnabled = false.obs;
  final isPermissionGranted = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotificationSettings();
  }

  /// Notification ayarlarını initialize et
  Future<void> _initializeNotificationSettings() async {
    try {
      isLoading.value = true;

      // Firebase token durumunu kontrol et
      await _checkFirebaseTokenStatus();

      // Sonra permission kontrolü yap (async)
      await checkNotificationPermission();
    } catch (e) {
      print('[NOTIFICATION] Error initializing settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Firebase token durumunu kontrol et
  Future<void> _checkFirebaseTokenStatus() async {
    try {
      // Önce notification ayarını kontrol et
      String? notificationEnabled =
          await _storage.read(key: 'notification_enabled');

      if (notificationEnabled == 'false') {
        isNotificationEnabled.value = false;
        print('[NOTIFICATION] Notifications disabled in settings');
        return;
      }

      // Notification enabled ise Firebase token'ı kontrol et
      String? firebaseToken = await _storage.read(key: 'firebase_token');
      isNotificationEnabled.value =
          firebaseToken != null && firebaseToken.isNotEmpty;
      print(
          '[NOTIFICATION] Firebase token status: ${firebaseToken != null ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('[NOTIFICATION] Error checking Firebase token status: $e');
      isNotificationEnabled.value = false;
    }
  }

  /// Notification permission durumunu kontrol et
  Future<void> checkNotificationPermission() async {
    try {
      // Notification permission durumunu kontrol et
      PermissionStatus status = await Permission.notification.status;
      isPermissionGranted.value = status.isGranted;

      // Eğer permission yoksa, notification'ı kapat
      if (!status.isGranted) {
        isNotificationEnabled.value = false;
        await _storage.delete(key: 'firebase_token');
      }
    } catch (e) {
      print('[NOTIFICATION] Error checking permission: $e');
    }
  }

  /// Notification switch'ini değiştir
  Future<void> toggleNotification(bool value) async {
    if (isLoading.value) return; // Zaten işlem varsa tekrar çalıştırma
    isLoading.value = true;

    try {
      PermissionStatus status = await Permission.notification.status;

      if (!status.isGranted) {
        await _openAppSettings();
        return;
      }

      // Permission varsa, notification ayarını değiştir
      if (value) {
        await _enableAppNotification();
      } else {
        await _disableAppNotification();
      }

      isNotificationEnabled.value = value;

      SnackbarUtils.showSuccessSnackbar(
        value ? 'notification_enabled'.tr : 'notification_disabled'.tr,
      );
    } catch (e) {
      print('[NOTIFICATION] Error toggling notification: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Uygulama dahili notification'ı etkinleştir
  Future<void> _enableAppNotification() async {
    try {
      // Notification ayarını storage'a kaydet
      await _storage.write(key: 'notification_enabled', value: 'true');

      // Firebase notification'ı etkinleştir
      await _firebaseService.enableNotifications();

      // Firebase token'ı al
      String? token = await _firebaseService.getAndSaveToken();

      if (token != null) {
        // Home API'ye notification enabled request'i gönder
        await _notificationsService.updateNotificationSettings(
            enabled: true, token: token);
        print(
            '[NOTIFICATION] App notification enabled successfully and sent to API');
      } else {
        throw Exception('Failed to get Firebase token');
      }
    } catch (e) {
      print('[NOTIFICATION] Error enabling app notification: $e');
      throw e;
    }
  }

  /// Uygulama dahili notification'ı devre dışı bırak
  Future<void> _disableAppNotification() async {
    try {
      // Notification ayarını storage'a kaydet
      await _storage.write(key: 'notification_enabled', value: 'false');

      // Firebase notification'ı devre dışı bırak
      await _firebaseService.disableNotifications();

      // Home API'ye notification disabled request'i gönder (token null)
      await _notificationsService.updateNotificationSettings(
          enabled: false, token: null);
      print(
          '[NOTIFICATION] App notification disabled successfully and sent to API');
    } catch (e) {
      print('[NOTIFICATION] Error disabling app notification: $e');
      throw e;
    }
  }

  /// App settings'e yönlendir
  Future<void> _openAppSettings() async {
    try {
      await AppSettings.openAppSettings();

      SnackbarUtils.showErrorSnackbar(
        'notification_permission_required'.tr,
      );
    } catch (e) {
      print('[NOTIFICATION] Error opening app settings: $e');
    }
  }

  /// App settings'den döndükten sonra permission'ı tekrar kontrol et
  Future<void> refreshPermissionStatus() async {
    await checkNotificationPermission();
    await _checkFirebaseTokenStatus();
  }
}
