import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_service.dart';

class NotificationsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl + '/people',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _secureStorage = SecureStorageConfig.storage;
  final GetStorage _storage = GetStorage();

  NotificationsService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await _secureStorage.read(key: SecureStorageConfig.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Get notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      print('[GET NOTIFICATIONS REQUEST]');
      final response = await _dio.get(
        '/notifications',
      );
      print('[GET NOTIFICATIONS RESPONSE] ' + response.data.toString());
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        print('[GET NOTIFICATIONS ERROR RESPONSE] ' +
            e.response!.data.toString());
        throw NotificationsException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        print('[GET NOTIFICATIONS ERROR] Ağ hatası: ' + e.toString());
        throw NotificationsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Invite response

  /// Update notification status
  Future<Map<String, dynamic>> updateNotificationStatus({
    required String notificationId,
    required String status, // "read" or "unread"
  }) async {
    try {
      print(
          '[UPDATE NOTIFICATION STATUS REQUEST] notificationId: $notificationId, status: $status');
      final response = await _dio.post(
        '/notifications/status',
        data: {
          'notification_id': notificationId,
          'status': status,
        },
      );
      print(
          '[UPDATE NOTIFICATION STATUS RESPONSE] ' + response.data.toString());
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        print('[UPDATE NOTIFICATION STATUS ERROR] ' +
            e.response!.data.toString());
        throw NotificationsException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        print('[UPDATE NOTIFICATION STATUS ERROR] Ağ hatası: ' + e.toString());
        throw NotificationsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Invite action (accept/ignore)
  Future<Map<String, dynamic>> inviteAction({
    required String notificationId,
    required String action, // "accept" or "ignore"
  }) async {
    try {
      print(
          '[INVITE ACTION REQUEST] notificationId: $notificationId, action: $action');
      final response = await _dio.post(
        '/notifications/invite-action',
        data: {
          'notification_id': notificationId,
          'action': action,
        },
      );
      print('[INVITE ACTION RESPONSE] ' + response.data.toString());
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        print('[INVITE ACTION ERROR] ' + e.response!.data.toString());
        throw NotificationsException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        print('[INVITE ACTION ERROR] Ağ hatası: ' + e.toString());
        throw NotificationsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Notification'ların etkin olup olmadığını kontrol et
  Future<bool> isNotificationEnabled() async {
    try {
      // GetStorage'dan notification ayarını kontrol et
      final notificationEnabled = _storage.read('notification_enabled') ?? true;
      return notificationEnabled;
    } catch (e) {
      print('[NOTIFICATIONS] Error checking notification status: $e');
      return true; // Default true
    }
  }

  /// Notification settings'i home API'ye gönder
  Future<Map<String, dynamic>> updateNotificationSettings({
    required bool enabled,
    String? token,
  }) async {
    try {
      print(
          '[UPDATE NOTIFICATION SETTINGS REQUEST] enabled: $enabled, token: ${token != null ? 'present' : 'null'}');

      final Map<String, dynamic> data = {
        'notification_enabled': enabled,
      };

      if (enabled && token != null) {
        data['firebase_token'] = token;
      }

      final response = await _dio.post(
        '/notification-settings',
        data: data,
      );

      print('[UPDATE NOTIFICATION SETTINGS RESPONSE] ' +
          response.data.toString());
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        print('[UPDATE NOTIFICATION SETTINGS ERROR] ' +
            e.response!.data.toString());
        throw NotificationsException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        print(
            '[UPDATE NOTIFICATION SETTINGS ERROR] Ağ hatası: ' + e.toString());
        throw NotificationsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Notification gösterilip gösterilmeyeceğini kontrol et
  Future<bool> shouldShowNotification() async {
    try {
      // Önce uygulama dahili ayarı kontrol et
      final appNotificationEnabled = await isNotificationEnabled();
      if (!appNotificationEnabled) {
        print(
            '[NOTIFICATIONS] App notification disabled, not showing notification');
        return false;
      }

      // Sonra Firebase permission'ını kontrol et
      final firebasePermission =
          await FirebaseMessaging.instance.requestPermission();
      if (firebasePermission.authorizationStatus !=
          AuthorizationStatus.authorized) {
        print(
            '[NOTIFICATIONS] Firebase permission denied, not showing notification');
        return false;
      }

      return true;
    } catch (e) {
      print('[NOTIFICATIONS] Error checking if should show notification: $e');
      return false;
    }
  }
}

class NotificationsException implements Exception {
  final String message;

  NotificationsException(this.message);

  @override
  String toString() => 'NotificationsException: $message';
}
