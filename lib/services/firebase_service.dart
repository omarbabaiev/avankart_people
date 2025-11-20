import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';


// Background message handler - top level function olmalı
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
      '[FIREBASE] Background message received: ${message.notification?.title}');
  // Background'da notification otomatik gösterilir
}

class FirebaseService {
  FirebaseMessaging? _messaging;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GetStorage _storage = GetStorage();

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? get _messagingInstance {
    if (_messaging == null) {
      try {
        _messaging = FirebaseMessaging.instance;
      } catch (e) {
        debugPrint('[FIREBASE] Error getting FirebaseMessaging instance: $e');
        return null;
      }
    }
    return _messaging;
  }

  // Check if Firebase is initialized
  bool get isInitialized => _messaging != null;

  /// Firebase'i initialize et
  Future<void> initialize() async {
    try {
      debugPrint('[FIREBASE] Initializing Firebase Messaging...');

      // Check if Firebase is initialized
      if (_messagingInstance == null) {
        debugPrint('[FIREBASE] Firebase not initialized yet, skipping...');
        return;
      }

      // Notification permissions
      NotificationSettings settings =
          await _messagingInstance!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          '[FIREBASE] Permission granted: ${settings.authorizationStatus}');

      // Background message handler'ı set et
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Token refresh listener
      setupTokenRefresh();

      // Notification handlers
      setupNotificationHandling();

      // GetStorage'dan notification ayarını kontrol et, sadece enabled ise token al
      final notificationEnabled = _storage.read('notification_enabled') ?? true;
      if (notificationEnabled) {
        // Initial token al
        await getAndSaveToken();
      } else {
        debugPrint('[FIREBASE] Notifications disabled, skipping initial token');
      }

      debugPrint('[FIREBASE] Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('[FIREBASE] Error initializing: $e');
    }
  }

  /// Token al ve sakla
  Future<String?> getAndSaveToken() async {
    try {
      if (_messagingInstance == null) {
        debugPrint('[FIREBASE] Firebase not initialized, cannot get token');
        return null;
      }

      // GetStorage'dan notification ayarını kontrol et
      final notificationEnabled = _storage.read('notification_enabled') ?? true;
      if (!notificationEnabled) {
        debugPrint('[FIREBASE] Notifications disabled, not getting token');
        return null;
      }

      String? token = await _messagingInstance!.getToken();
      if (token != null) {
        await _secureStorage.write(key: 'firebase_token', value: token);
        debugPrint('[FIREBASE] Token saved: ${token.substring(0, 20)}...');
      } else {
        debugPrint('[FIREBASE] Failed to get token');
      }
      return token;
    } catch (e) {
      debugPrint('[FIREBASE] Error getting token: $e');
      return null;
    }
  }

  /// Saklanan token'ı al
  Future<String?> getStoredToken() async {
    try {
      String? token = await _secureStorage.read(key: 'firebase_token');
      if (token == null) {
        // Token yoksa yeniden al
        token = await getAndSaveToken();
      }
      return token;
    } catch (e) {
      debugPrint('[FIREBASE] Error getting stored token: $e');
      return null;
    }
  }

  /// Token refresh listener
  void setupTokenRefresh() {
    if (_messagingInstance == null) {
      debugPrint(
          '[FIREBASE] Firebase not initialized, cannot setup token refresh');
      return;
    }

    _messagingInstance!.onTokenRefresh.listen((newToken) async {
      try {
        // GetStorage'dan notification ayarını kontrol et
        final notificationEnabled =
            _storage.read('notification_enabled') ?? true;
        if (!notificationEnabled) {
          debugPrint(
              '[FIREBASE] Notifications disabled, ignoring token refresh');
          return;
        }

        await _secureStorage.write(key: 'firebase_token', value: newToken);
        debugPrint(
            '[FIREBASE] Token refreshed: ${newToken.substring(0, 20)}...');

        // Backend'e yeni token'ı gönder (opsiyonel)
        await _updateTokenOnBackend(newToken);
      } catch (e) {
        debugPrint('[FIREBASE] Error handling token refresh: $e');
      }
    });
  }

  /// Backend'e token güncelleme (opsiyonel)
  Future<void> _updateTokenOnBackend(String newToken) async {
    try {
      // Burada backend'e token güncelleme API'si çağrılabilir
      // Şimdilik sadece log atıyoruz
      debugPrint(
          '[FIREBASE] Token updated on backend: ${newToken.substring(0, 20)}...');
    } catch (e) {
      debugPrint('[FIREBASE] Error updating token on backend: $e');
    }
  }

  /// Notification handling setup
  void setupNotificationHandling() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          '[FIREBASE] Foreground message received: ${message.notification?.title}');

      // Notification göster
      _showForegroundNotification(message);
    });

    // Background/Terminated app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          '[FIREBASE] App opened from notification: ${message.notification?.title}');

      // Navigate to specific screen based on notification data
      _handleNotificationNavigation(message);
    });

    // Check if app was opened from notification when terminated
    if (_messagingInstance != null) {
      _messagingInstance!.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint(
              '[FIREBASE] App opened from terminated state: ${message.notification?.title}');
          _handleNotificationNavigation(message);
        }
      });
    }
  }

  /// Foreground notification göster
  void _showForegroundNotification(RemoteMessage message) async {
    try {
      // Notification kontrolü yap
      final shouldShow = await _shouldShowNotification();
      if (!shouldShow) {
        debugPrint(
            '[FIREBASE] Notification disabled, not showing foreground notification');
        return;
      }

      // GetX snackbar ile notification göster
      SnackbarUtils.showSuccessSnackbar(
        message.notification?.title ?? 'new_notification.tr',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('[FIREBASE] Error showing foreground notification: $e');
    }
  }

  /// Notification gösterilip gösterilmeyeceğini kontrol et
  Future<bool> _shouldShowNotification() async {
    try {
      // GetStorage'dan notification ayarını kontrol et
      final notificationEnabled = _storage.read('notification_enabled') ?? true;
      return notificationEnabled;
    } catch (e) {
      debugPrint('[FIREBASE] Error checking notification status: $e');
      return true; // Hata durumunda varsayılan olarak göster
    }
  }

  /// Notification navigation handling
  void _handleNotificationNavigation(RemoteMessage message) {
    // Notification data'sına göre navigation
    if (message.data.containsKey('screen')) {
      String screen = message.data['screen'];
      switch (screen) {
        case 'home':
          // Home screen'e git
          break;
        case 'notifications':
          // Notifications screen'e git
          break;
        case 'profile':
          // Profile screen'e git
          break;
        default:
          // Default navigation
          break;
      }
    }
  }

  /// Topic'e subscribe ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (_messagingInstance == null) {
        debugPrint(
            '[FIREBASE] Firebase not initialized, cannot subscribe to topic');
        return;
      }
      await _messagingInstance!.subscribeToTopic(topic);
      debugPrint('[FIREBASE] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FIREBASE] Error subscribing to topic: $e');
    }
  }

  /// Topic'ten unsubscribe ol
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_messagingInstance == null) {
        debugPrint(
            '[FIREBASE] Firebase not initialized, cannot unsubscribe from topic');
        return;
      }
      await _messagingInstance!.unsubscribeFromTopic(topic);
      debugPrint('[FIREBASE] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[FIREBASE] Error unsubscribing from topic: $e');
    }
  }

  /// Token'ı temizle (logout sırasında)
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'firebase_token');
      debugPrint('[FIREBASE] Token cleared');
    } catch (e) {
      debugPrint('[FIREBASE] Error clearing token: $e');
    }
  }

  /// Notification badge sayısını temizle (iOS için)
  Future<void> clearBadge() async {
    try {
      // iOS için badge temizleme - şimdilik boş bırakıyoruz
      // await _messaging.setBadge(0);
      debugPrint('[FIREBASE] Badge cleared');
    } catch (e) {
      debugPrint('[FIREBASE] Error clearing badge: $e');
    }
  }

  /// Notification'ları etkinleştir
  Future<void> enableNotifications() async {
    try {
      if (_messagingInstance == null) {
        debugPrint(
            '[FIREBASE] Firebase not initialized, cannot enable notifications');
        return;
      }

      // Notification permission'ı tekrar iste
      NotificationSettings settings =
          await _messagingInstance!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Token'ı yenile
        await getAndSaveToken();

        // Varsayılan topic'e subscribe ol
        await subscribeToTopic('general');

        debugPrint('[FIREBASE] Notifications enabled successfully');
      } else {
        debugPrint('[FIREBASE] Notification permission denied');
        throw Exception('Notification permission denied');
      }
    } catch (e) {
      debugPrint('[FIREBASE] Error enabling notifications: $e');
      throw e;
    }
  }

  /// Notification'ları devre dışı bırak
  Future<void> disableNotifications() async {
    try {
      if (_messagingInstance == null) {
        debugPrint(
            '[FIREBASE] Firebase not initialized, cannot disable notifications');
        return;
      }

      // Token'ı temizle
      await clearToken();

      // Topic'ten unsubscribe ol
      await unsubscribeFromTopic('general');

      debugPrint('[FIREBASE] Notifications disabled successfully');
    } catch (e) {
      debugPrint('[FIREBASE] Error disabling notifications: $e');
      throw e;
    }
  }
}
