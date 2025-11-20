import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '../services/firebase_service.dart';
import '../services/notifications_service.dart';
import '../utils/api_response_parser.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/snackbar_utils.dart';

class NotificationSettingsController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationsService _notificationsService = NotificationsService();
  final GetStorage _storage = GetStorage();

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

      // Önce notification_enabled flag'ini kontrol et
      await _checkNotificationEnabledFlag();

      // Sonra permission kontrolü yap
      await checkNotificationPermission();
    } catch (e) {
      debugPrint('[NOTIFICATION] Error initializing settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Notification enabled flag'ini kontrol et
  Future<void> _checkNotificationEnabledFlag() async {
    try {
      // GetStorage'dan notification_enabled değerini oku
      bool? notificationEnabled = _storage.read('notification_enabled');

      if (notificationEnabled == null) {
        // İlk kez açılıyorsa default olarak true yap
        _storage.write('notification_enabled', true);
        isNotificationEnabled.value = true;
        debugPrint(
            '[NOTIFICATION] First login - notifications enabled by default');
      } else {
        // Daha önce ayarlanmışsa o değeri kullan
        isNotificationEnabled.value = notificationEnabled;
        debugPrint(
            '[NOTIFICATION] Notification setting loaded: $notificationEnabled');
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Error checking notification enabled flag: $e');
      isNotificationEnabled.value = true; // Default olarak true
    }
  }

  /// Notification permission durumunu kontrol et
  Future<void> checkNotificationPermission() async {
    try {
      // Notification permission durumunu kontrol et (sadece bilgilendirme amaçlı)
      PermissionStatus status = await Permission.notification.status;
      isPermissionGranted.value = status.isGranted;

      // Permission durumu notification ayarını etkilemez
      // Sadece bilgilendirme amaçlı tutulur
      debugPrint(
          '[NOTIFICATION] Permission status: ${status.isGranted ? 'granted' : 'denied'}');
    } catch (e) {
      debugPrint('[NOTIFICATION] Error checking permission: $e');
    }
  }

  /// Notification switch'ini değiştir
  Future<void> toggleNotification(bool value) async {
    if (isLoading.value) return; // Zaten işlem varsa tekrar çalıştırma
    isLoading.value = true;

    try {
      // Permission kontrolü yapmadan direkt notification ayarını değiştir
      if (value) {
        await _enableAppNotification();
      } else {
        await _disableAppNotification();
      }

      // UI'ı güncelle
      isNotificationEnabled.value = value;

      SnackbarUtils.showSuccessSnackbar(
        value ? 'notification_enabled'.tr : 'notification_disabled'.tr,
      );
    } catch (e) {
      debugPrint('[NOTIFICATION] Error toggling notification: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// Uygulama dahili notification'ı etkinleştir
  Future<void> _enableAppNotification() async {
    try {
      // GetStorage'a notification enabled olarak kaydet
      _storage.write('notification_enabled', true);

      // Firebase notification'ı etkinleştir
      await _firebaseService.enableNotifications();

      // Firebase token'ı al
      String? token = await _firebaseService.getAndSaveToken();

      if (token != null) {
        // Home API'ye notification enabled request'i gönder
        await _notificationsService.updateNotificationSettings(
            enabled: true, token: token);
        debugPrint(
            '[NOTIFICATION] App notification enabled successfully and sent to API');
      } else {
        throw Exception('Failed to get Firebase token');
      }
    } catch (e) {
      debugPrint('[NOTIFICATION] Error enabling app notification: $e');
      throw e;
    }
  }

  /// Uygulama dahili notification'ı devre dışı bırak
  Future<void> _disableAppNotification() async {
    try {
      // GetStorage'a notification disabled olarak kaydet
      _storage.write('notification_enabled', false);

      // Firebase notification'ı devre dışı bırak
      await _firebaseService.disableNotifications();

      // Home API'ye notification disabled request'i gönder (token null)
      await _notificationsService.updateNotificationSettings(
          enabled: false, token: null);
      debugPrint(
          '[NOTIFICATION] App notification disabled successfully and sent to API');
    } catch (e) {
      debugPrint('[NOTIFICATION] Error disabling app notification: $e');
      throw e;
    }
  }

  /// App settings'den döndükten sonra permission'ı tekrar kontrol et
  Future<void> refreshPermissionStatus() async {
    await checkNotificationPermission();
    await _checkNotificationEnabledFlag();
  }

  /// Cihazın uygulama bildirim ayarlarını aç
  Future<void> openAppNotificationSettings() async {
    try {
      debugPrint('[NOTIFICATION] Opening app notification settings...');
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      debugPrint('[NOTIFICATION] App notification settings opened');
    } catch (e) {
      debugPrint('[NOTIFICATION] Error opening app notification settings: $e');
      SnackbarUtils.showErrorSnackbar('notification_settings_error'.tr);
    }
  }

  /// Uygulama açıldığında notification durumunu API'ye gönder
  Future<void> syncNotificationStatusOnAppStart() async {
    try {
      debugPrint('[NOTIFICATION] Syncing notification status on app start...');

      // GetStorage'dan notification durumunu kontrol et
      bool notificationEnabled = _storage.read('notification_enabled') ?? true;

      if (notificationEnabled) {
        // Notification açıksa, Firebase token'ı al ve API'ye gönder
        String? firebaseToken = await _firebaseService.getStoredToken();
        if (firebaseToken != null && firebaseToken.isNotEmpty) {
          await _notificationsService.updateNotificationSettings(
              enabled: true, token: firebaseToken);
          debugPrint(
              '[NOTIFICATION] App start: Notification enabled, token sent to API');
        } else {
          // Token yoksa yeni token almayı dene
          firebaseToken = await _firebaseService.getAndSaveToken();
          if (firebaseToken != null) {
            await _notificationsService.updateNotificationSettings(
                enabled: true, token: firebaseToken);
            debugPrint('[NOTIFICATION] New token generated and sent to API');
          } else {
            // Token alınamazsa notification'ı kapat
            _storage.write('notification_enabled', false);
            await _notificationsService.updateNotificationSettings(
                enabled: false, token: null);
            debugPrint(
                '[NOTIFICATION] Failed to get token, notifications disabled');
          }
        }
      } else {
        // Notification kapalıysa, API'ye disabled gönder
        await _notificationsService.updateNotificationSettings(
            enabled: false, token: null);
        debugPrint(
            '[NOTIFICATION] App start: Notification disabled, sent to API');
      }
    } catch (e) {
      debugPrint(
          '[NOTIFICATION] Error syncing notification status on app start: $e');
    }
  }
}
