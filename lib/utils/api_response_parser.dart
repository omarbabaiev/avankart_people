import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiResponseParser {
  /// API'den gelen mesajı localization'a uygun şekilde parse eder
  /// Eğer localization'da key varsa onu göster, yoksa API mesajını göster
  static String parseApiMessage(dynamic apiMessage) {
    if (apiMessage == null) {
      return 'unknown_error'.tr;
    }

    // String'e çevir
    String message;

    // Eğer Map ise, uygun field'ı çıkar
    if (apiMessage is Map) {
      final messageStr =
          apiMessage['message'] ?? apiMessage['text'] ?? apiMessage['msg'];

      // messageStr de Map olabilir (nested Map durumu)
      if (messageStr is Map) {
        // Nested Map'ten String değer çıkarmaya çalış
        final nestedMessage =
            messageStr['message'] ?? messageStr['text'] ?? messageStr['msg'];
        if (nestedMessage is String && nestedMessage.isNotEmpty) {
          message = nestedMessage;
        } else {
          // Nested Map'te de String bulunamadıysa, JSON'u string'e çevir
          debugPrint(
              '[API PARSER] Message is nested Map but no valid string field found: $apiMessage');
          return 'unknown_error'.tr;
        }
      } else if (messageStr is String && messageStr.isNotEmpty) {
        message = messageStr;
      } else {
        debugPrint(
            '[API PARSER] Message is Map but no valid string field found: $apiMessage');
        return 'unknown_error'.tr;
      }
    } else {
      // Map değilse direkt String'e çevir
      message = apiMessage.toString();
    }

    if (message.isEmpty) {
      return 'unknown_error'.tr;
    }

    // Auth hataları
    if (message.toLowerCase().contains('auth.username_or_password')) {
      debugPrint(
          '[API PARSER] Username or password error detected, using auth.username_or_password');
      return 'auth.username_or_password'.tr;
    }

    if (message.toLowerCase().contains('auth.email_or_phone_suffix')) {
      debugPrint(
          '[API PARSER] Email or phone suffix error detected, using auth.email_or_phone_suffix');
      return 'auth.email_or_phone_suffix'.tr;
    }

    if (message.toLowerCase().contains('auth.email_already_exist')) {
      debugPrint(
          '[API PARSER] Email already exists error detected, using auth.email_already_exist');
      return 'auth.email_already_exist'.tr;
    }

    if (message.toLowerCase().contains('invalid token')) {
      debugPrint(
          '[API PARSER] Invalid token detected, using auth.invalid_token');
      return 'auth.invalid_token'.tr;
    }

    if (message.toLowerCase().contains('otp already verified')) {
      debugPrint(
          '[API PARSER] OTP already verified detected, using error.otp_already_verified');
      return 'error.otp_already_verified'.tr;
    }

    if (message.toLowerCase().contains('invalid otp')) {
      debugPrint('[API PARSER] Invalid OTP detected, using error.invalid_otp');
      return 'error.invalid_otp'.tr;
    }

    if (message.toLowerCase().contains('otp expired')) {
      debugPrint('[API PARSER] OTP expired detected, using error.otp_expired');
      return 'error.otp_expired'.tr;
    }

    if (message.toLowerCase().contains('otp doğrulanmayıb') ||
        message.toLowerCase().contains('otp not verified') ||
        message.toLowerCase().contains('otp doğrulanmadı') ||
        message.toLowerCase().contains('otp не подтвержден')) {
      debugPrint(
          '[API PARSER] OTP not verified detected, using error.otp_not_verified');
      return 'error.otp_not_verified'.tr;
    }

    if (message.toLowerCase().contains('old password is required')) {
      debugPrint(
          '[API PARSER] Old password required detected, using error.old_password_required');
      return 'error.old_password_required'.tr;
    }

    if (message.toLowerCase().contains('passwords do not match')) {
      debugPrint(
          '[API PARSER] Passwords do not match detected, using error.passwords_dont_match');
      return 'error.passwords_dont_match'.tr;
    }

    // Profile hataları
    if (message.toLowerCase().contains('user not found')) {
      debugPrint(
          '[API PARSER] User not found detected, using error.user_not_found');
      return 'error.user_not_found'.tr;
    }

    if (message.toLowerCase().contains('phone is required')) {
      debugPrint(
          '[API PARSER] Phone is required detected, using error.phone_required');
      return 'error.phone_required'.tr;
    }

    if (message.toLowerCase().contains('birth date is required')) {
      debugPrint(
          '[API PARSER] Birth date is required detected, using error.birth_date_required');
      return 'error.birth_date_required'.tr;
    }

    if (message.toLowerCase().contains('name is required')) {
      debugPrint(
          '[API PARSER] Name is required detected, using error.name_required');
      return 'error.name_required'.tr;
    }

    if (message.toLowerCase().contains('email is required')) {
      debugPrint(
          '[API PARSER] Email is required detected, using error.email_required');
      return 'error.email_required'.tr;
    }

    if (message.toLowerCase().contains('email already exists')) {
      debugPrint(
          '[API PARSER] Email already exists detected, using error.email_already_exists');
      return 'error.email_already_exists'.tr;
    }

    // QR Payment hataları
    if (message.toLowerCase().contains('qr code not found')) {
      debugPrint(
          '[API PARSER] QR code not found detected, using error.qr_code_not_found');
      return 'error.qr_code_not_found'.tr;
    }

    if (message.toLowerCase().contains('change request not found')) {
      debugPrint(
          '[API PARSER] Change request not found detected, using error.change_request_not_found');
      return 'error.change_request_not_found'.tr;
    }

    if (message.toLowerCase().contains('not a delete request')) {
      debugPrint(
          '[API PARSER] Not a delete request detected, using error.not_delete_request');
      return 'error.not_delete_request'.tr;
    }

    if (message.toLowerCase().contains('cannot send otp')) {
      debugPrint(
          '[API PARSER] Cannot send OTP detected, using error.cannot_send_otp');
      return 'error.cannot_send_otp'.tr;
    }

    if (message.toLowerCase().contains('internal server error')) {
      debugPrint(
          '[API PARSER] Internal server error detected, using error.internal_server_error');
      return 'error.internal_server_error'.tr;
    }

    // QR Code hataları
    if (message.toLowerCase().contains('qr code info missing')) {
      debugPrint(
          '[API PARSER] QR code info missing detected, using qr_code_info_missing');
      return 'qr_code_info_missing'.tr;
    }

    if (message.toLowerCase().contains('qr code generation failed')) {
      debugPrint(
          '[API PARSER] QR code generation failed detected, using qr_code_generation_failed');
      return 'qr_code_generation_failed'.tr;
    }

    if (message.toLowerCase().contains('qr code cancellation failed')) {
      debugPrint(
          '[API PARSER] QR code cancellation failed detected, using qr_code_cancellation_failed');
      return 'qr_code_cancellation_failed'.tr;
    }

    if (message.toLowerCase().contains('qr code check failed')) {
      debugPrint(
          '[API PARSER] QR code check failed detected, using qr_code_check_failed');
      return 'qr_code_check_failed'.tr;
    }

    if (message.toLowerCase().contains('qr kod ləğv edildi')) {
      debugPrint(
          '[API PARSER] QR code canceled detected, using qr_code_canceled');
      return 'qr_code_canceled'.tr;
    }

    // Notification hataları
    if (message.toLowerCase().contains('notification load failed')) {
      debugPrint(
          '[API PARSER] Notification load failed detected, using notification_load_failed');
      return 'notification_load_failed'.tr;
    }

    if (message.toLowerCase().contains('invite response failed')) {
      debugPrint(
          '[API PARSER] Invite response failed detected, using invite_response_failed');
      return 'invite_response_failed'.tr;
    }

    if (message.toLowerCase().contains('notification status update failed')) {
      debugPrint(
          '[API PARSER] Notification status update failed detected, using notification_status_update_failed');
      return 'notification_status_update_failed'.tr;
    }

    // Success mesajları
    if (message.toLowerCase().contains('otp sent successfully')) {
      debugPrint(
          '[API PARSER] OTP sent successfully detected, using success.otp_sent');
      return 'success.otp_sent'.tr;
    }

    if (message.toLowerCase().contains('otp verified')) {
      debugPrint(
          '[API PARSER] OTP verified detected, using success.otp_verified');
      return 'success.otp_verified'.tr;
    }

    if (message.toLowerCase().contains('change request received')) {
      debugPrint(
          '[API PARSER] Change request received detected, using success.change_request_received');
      return 'success.change_request_received'.tr;
    }

    if (message.toLowerCase().contains('profile updated successfully')) {
      debugPrint(
          '[API PARSER] Profile updated successfully detected, using success.profile_updated');
      return 'success.profile_updated'.tr;
    }

    if (message.toLowerCase().contains('account deleted')) {
      debugPrint(
          '[API PARSER] Account deleted detected, using success.account_deleted');
      return 'success.account_deleted'.tr;
    }

    if (message.toLowerCase().contains('otp resent successfully')) {
      debugPrint(
          '[API PARSER] OTP resent successfully detected, using success.otp_resent');
      return 'success.otp_resent'.tr;
    }

    if (message
        .toLowerCase()
        .contains('change request cancelled successfully')) {
      debugPrint(
          '[API PARSER] Change request cancelled successfully detected, using success.change_request_cancelled');
      return 'success.change_request_cancelled'.tr;
    }

    // Responses.json'dan gelen yeni mesajlar
    if (message.toLowerCase().contains('your login has been restricted')) {
      debugPrint(
          '[API PARSER] Login restricted detected, using auth.login_restricted');
      return 'auth.login_restricted'.tr;
    }

    if (message.toLowerCase().contains('otp verification required')) {
      debugPrint(
          '[API PARSER] OTP verification required detected, using auth.otp_required');
      return 'auth.otp_required'.tr;
    }

    if (message.toLowerCase().contains('auth.phone_already_exist')) {
      debugPrint(
          '[API PARSER] Phone already exists detected, using auth.phone_already_exist');
      return 'auth.phone_already_exist'.tr;
    }

    if (message.toLowerCase().contains('otp not found or has expired')) {
      debugPrint(
          '[API PARSER] OTP not found or expired detected, using auth.otp_expired_or_not_found');
      return 'auth.otp_expired_or_not_found'.tr;
    }

    if (message.toLowerCase().contains('token missing')) {
      debugPrint(
          '[API PARSER] Token missing detected, using auth.token_missing');
      return 'auth.token_missing'.tr;
    }

    if (message.toLowerCase().contains('logged out')) {
      debugPrint('[API PARSER] Logged out detected, using auth.logged_out');
      return 'auth.logged_out'.tr;
    }

    if (message.toLowerCase().contains('error during logout')) {
      debugPrint('[API PARSER] Logout error detected, using auth.logout_error');
      return 'auth.logout_error'.tr;
    }

    if (message.toLowerCase().contains('password updated')) {
      debugPrint(
          '[API PARSER] Password updated detected, using auth.password_updated');
      return 'auth.password_updated'.tr;
    }

    if (message.toLowerCase().contains('email and otp are required')) {
      debugPrint(
          '[API PARSER] Email and OTP required detected, using otp.email_and_code_required');
      return 'otp.email_and_code_required'.tr;
    }

    if (message.toLowerCase().contains('unsupported otp method')) {
      debugPrint(
          '[API PARSER] Unsupported OTP method detected, using otp.method_unsupported');
      return 'otp.method_unsupported'.tr;
    }

    if (message.toLowerCase().contains('otp not found, please request again')) {
      debugPrint(
          '[API PARSER] OTP not found request again detected, using otp.not_found_request_again');
      return 'otp.not_found_request_again'.tr;
    }

    if (message.toLowerCase().contains('otp is invalid (3 attempts)')) {
      debugPrint(
          '[API PARSER] OTP invalid 3 attempts detected, using otp.invalid_3_attempts');
      return 'otp.invalid_3_attempts'.tr;
    }

    if (message.toLowerCase().contains('too many attempts')) {
      debugPrint(
          '[API PARSER] Too many attempts detected, using otp.too_many_attempts');
      return 'otp.too_many_attempts'.tr;
    }

    if (message.toLowerCase().contains('otp cancelled')) {
      debugPrint('[API PARSER] OTP cancelled detected, using otp.cancelled');
      return 'otp.cancelled'.tr;
    }

    if (message.toLowerCase().contains('otp not found for this email')) {
      debugPrint(
          '[API PARSER] OTP not found for email detected, using otp.not_found_for_email');
      return 'otp.not_found_for_email'.tr;
    }

    if (message.toLowerCase().contains('retry limit exceeded')) {
      debugPrint(
          '[API PARSER] Retry limit exceeded detected, using otp.retry_limit_exceeded');
      return 'otp.retry_limit_exceeded'.tr;
    }

    if (message.toLowerCase().contains('invalid page number')) {
      debugPrint(
          '[API PARSER] Invalid page number detected, using notif.invalid_page');
      return 'notif.invalid_page'.tr;
    }

    if (message.toLowerCase().contains('invalid filter value')) {
      debugPrint(
          '[API PARSER] Invalid filter value detected, using notif.invalid_filter');
      return 'notif.invalid_filter'.tr;
    }

    if (message.toLowerCase().contains('invalid status value')) {
      debugPrint(
          '[API PARSER] Invalid status value detected, using notif.invalid_status');
      return 'notif.invalid_status'.tr;
    }

    if (message.toLowerCase().contains('invalid value')) {
      debugPrint('[API PARSER] Invalid value detected, using invalid_value');
      return 'invalid_value'.tr;
    }

    if (message.toLowerCase().contains('notification not found')) {
      debugPrint(
          '[API PARSER] Notification not found detected, using notif.not_found');
      return 'notif.not_found'.tr;
    }

    if (message.toLowerCase().contains('status was already up to date')) {
      debugPrint(
          '[API PARSER] Status no change detected, using notif.status_nochange');
      return 'notif.status_nochange'.tr;
    }

    if (message.toLowerCase().contains('notification status updated')) {
      debugPrint(
          '[API PARSER] Notification status updated detected, using notif.status_updated');
      return 'notif.status_updated'.tr;
    }

    if (message
        .toLowerCase()
        .contains('notification not found or not an invitation')) {
      debugPrint(
          '[API PARSER] Invite not found or invalid detected, using invite.not_found_or_invalid');
      return 'invite.not_found_or_invalid'.tr;
    }

    if (message.toLowerCase().contains('invitation ignored')) {
      debugPrint(
          '[API PARSER] Invitation ignored detected, using invite.ignored');
      return 'invite.ignored'.tr;
    }

    if (message.toLowerCase().contains('invitation accepted')) {
      debugPrint(
          '[API PARSER] Invitation accepted detected, using invite.accepted');
      return 'invite.accepted'.tr;
    }

    if (message.toLowerCase().contains('invalid action')) {
      debugPrint(
          '[API PARSER] Invalid action detected, using invite.invalid_action');
      return 'invite.invalid_action'.tr;
    }

    if (message.toLowerCase().contains('old password is incorrect') ||
        message.toLowerCase().contains('old password incorrect')) {
      debugPrint(
          '[API PARSER] Old password incorrect detected, using profile.old_password_incorrect');
      return 'profile.old_password_incorrect'.tr;
    }

    if (message.toLowerCase().contains('failed to send otp')) {
      debugPrint(
          '[API PARSER] OTP send failed detected, using profile.otp_send_failed');
      return 'profile.otp_send_failed'.tr;
    }

    if (message
        .toLowerCase()
        .contains('only pending qr codes can be canceled')) {
      debugPrint(
          '[API PARSER] Only pending QR cancellable detected, using qr.only_pending_cancellable');
      return 'qr.only_pending_cancellable'.tr;
    }

    if (message.toLowerCase().contains('qr code has been canceled')) {
      debugPrint('[API PARSER] QR canceled OK detected, using qr.canceled_ok');
      return 'qr.canceled_ok'.tr;
    }

    if (message.toLowerCase().contains('organization not found')) {
      debugPrint(
          '[API PARSER] Organization not found detected, using org.not_found');
      return 'org.not_found'.tr;
    }

    if (message
        .toLowerCase()
        .contains('price is required and must be a valid number')) {
      debugPrint(
          '[API PARSER] Price required invalid detected, using price.required_invalid');
      return 'price.required_invalid'.tr;
    }

    if (message.toLowerCase().contains('failed to generate qr code image')) {
      debugPrint(
          '[API PARSER] QR image generation failed detected, using qr.image_generation_failed');
      return 'qr.image_generation_failed'.tr;
    }

    if (message.toLowerCase().contains('code is required')) {
      debugPrint('[API PARSER] Code required detected, using code.required');
      return 'code.required'.tr;
    }

    if (message.toLowerCase().contains('user id is required')) {
      debugPrint(
          '[API PARSER] User ID required detected, using user_id.required');
      return 'user_id.required'.tr;
    }

    if (message.toLowerCase().contains('qr code not found!')) {
      debugPrint(
          '[API PARSER] QR not found EN detected, using qr.not_found_en');
      return 'qr.not_found_en'.tr;
    }

    if (message.toLowerCase().contains('unknown status value')) {
      debugPrint(
          '[API PARSER] QR unknown status detected, using qr.unknown_status');
      return 'qr.unknown_status'.tr;
    }

    if (message.toLowerCase().contains('internal server error!')) {
      debugPrint(
          '[API PARSER] Server internal error bang detected, using server.internal_error_bang');
      return 'server.internal_error_bang'.tr;
    }

    if (message.toLowerCase().contains('no delete request found')) {
      debugPrint(
          '[API PARSER] Delete request not found detected, using delete_request.not_found');
      return 'delete_request.not_found'.tr;
    }

    // API mesajı key formatında mı kontrol et (örn: auth.username_or_password)
    if (message.contains('.')) {
      // Localization'da bu key var mı kontrol et
      try {
        final localizedMessage = message.tr;
        // Eğer tr() metodu aynı string'i döndürüyorsa, localization'da yok demektir
        if (localizedMessage != message) {
          debugPrint(
              '[API PARSER] Localized message found: $message -> $localizedMessage');
          return localizedMessage;
        } else {
          debugPrint(
              '[API PARSER] No localization found for: $message, using original');
          return message;
        }
      } catch (e) {
        debugPrint(
            '[API PARSER] Error parsing message: $message, using original');
        return message;
      }
    }

    // Key formatında değilse direkt döndür
    debugPrint('[API PARSER] Message is not in key format: $message');
    // Known plain-text → translation key mapping (for backend plain messages)
    final lower = message.toLowerCase().trim();
    const knownMap = {
      'invalid pin code': 'pin_code_error',
    };
    for (final entry in knownMap.entries) {
      if (lower == entry.key) {
        return entry.value.tr;
      }
    }
    return message;
  }

  /// API response'dan error mesajını parse eder
  static String parseApiError(dynamic responseData) {
    if (responseData == null) {
      return 'unknown_error'.tr;
    }

    // Map ise message veya error field'ını ara
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ??
          responseData['error'] ??
          responseData['msg'];
      if (message != null) {
        // Eğer message field'ı da Map ise, içinden asıl mesajı çıkar
        if (message is Map) {
          // Nested map'ten message veya text field'ını al
          final nestedMessage =
              message['message'] ?? message['text'] ?? message['msg'];
          if (nestedMessage is String) {
            return parseApiMessage(nestedMessage);
          }
          // Eğer nested message de Map ise, daha derin bir seviyeye in
          if (nestedMessage is Map) {
            final deepNestedMessage = nestedMessage['message'] ??
                nestedMessage['text'] ??
                nestedMessage['msg'];
            if (deepNestedMessage is String) {
              return parseApiMessage(deepNestedMessage);
            }
          }
          // Hiçbir String bulunamadıysa, unknown error döndür
          debugPrint(
              '[API PARSER] Message is deeply nested Map, no string found: $responseData');
          return 'unknown_error'.tr;
        }
        // String ise direkt parse et - toString() yerine direkt message kullan
        if (message is String) {
          return parseApiMessage(message);
        }
        // Diğer tipler için toString() kullan
        return parseApiMessage(message.toString());
      }
    }

    // String ise direkt parse et
    if (responseData is String) {
      return parseApiMessage(responseData);
    }

    // Diğer durumlar için toString() kullan
    return parseApiMessage(responseData.toString());
  }

  /// DioException'dan error mesajını parse eder
  static String parseDioError(dynamic error) {
    if (error == null) {
      return 'unknown_error'.tr;
    }

    // Custom exception'ları kontrol et (CompaniesException, AuthException, vb.)
    // Bu exception'ların message field'ı var
    try {
      // Exception'ın message property'sine erişmeyi dene
      final errorType = error.runtimeType.toString();
      if (errorType.contains('Exception')) {
        // Exception'ın message field'ını al
        if (error is Exception) {
          final errorStr = error.toString();
          // "ExceptionType: message" formatında gelir
          if (errorStr.contains(':')) {
            final message = errorStr.split(':').skip(1).join(':').trim();
            return parseApiMessage(message);
          }
        }
      }
    } catch (e) {
      debugPrint('[API PARSER] Error extracting exception message: $e');
    }

    // DioException ise response data'sını parse et
    if (error.toString().contains('DioException')) {
      try {
        // DioException'dan response data'sını çıkarmaya çalış
        final errorString = error.toString();
        if (errorString.contains('Response:')) {
          final responsePart = errorString.split('Response:').last;
          return parseApiError(responsePart);
        }
      } catch (e) {
        debugPrint('[API PARSER] Error parsing DioException: $e');
      }
    }

    // Connection timeout hataları için spesifik kontrol
    final errorStrLower = error.toString().toLowerCase();
    if (errorStrLower.contains('connection took longer') ||
        errorStrLower.contains('connection timeout') ||
        errorStrLower.contains('the request connection took longer')) {
      debugPrint(
          '[API PARSER] Connection timeout detected, using error.connection_timeout');
      return 'error.connection_timeout'.tr;
    }

    // Network hataları için özel kontrol
    if (errorStrLower.contains('network') ||
        errorStrLower.contains('connection') ||
        errorStrLower.contains('timeout')) {
      return 'network_error_retry'.tr;
    }

    // Diğer durumlar için toString() kullan - ama önce String olduğundan emin ol
    final errorStr = error.toString();
    return parseApiMessage(errorStr);
  }
}
