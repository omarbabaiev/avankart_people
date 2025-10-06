import 'package:avankart_people/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/models/qr_check_response_model.dart';

class QrService {
  final Dio _dio = Dio();

  QrService() {
    _dio.options.baseUrl = AuthService.baseUrl + '/people';

    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Interceptor ekle
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Token'ı header'a ekle
        final token = await SecureStorageConfig.storage
            .read(key: SecureStorageConfig.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        DebugLogger.apiError('QR Service', error);
        handler.next(error);
      },
    ));
  }

  // Check QR Code - QR kodunu kontrol et
  Future<QrCheckResponseModel?> checkQrCode({
    required String qrCode,
    required String cardId,
  }) async {
    try {
      print('[QR SERVICE] ===== CHECK QR CODE DEBUG =====');
      print('[QR SERVICE] QR Code: $qrCode');
      print('[QR SERVICE] Card ID: $cardId');

      final requestData = {
        'qr_code': qrCode,
        'card_id': cardId,
      };

      print('[QR SERVICE] Request data: $requestData');
      print('[QR SERVICE] ===============================');

      DebugLogger.apiRequest('/action/checkQr', requestData);

      final response = await _dio.post(
        '/action/checkQr',
        data: requestData,
      );

      DebugLogger.apiResponse('/action/checkQr', response.data);

      if (response.data['success'] == true) {
        return QrCheckResponseModel.fromJson(response.data);
      } else {
        throw QrException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/action/checkQr', e);

      if (e.response != null && e.response?.data != null) {
        throw QrException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw QrException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Check QR Status - QR kod durumunu kontrol et
  Future<QrStatusResponse?> checkQrStatus({
    required String qrCodeId,
    required String cardId,
  }) async {
    try {
      print('[QR SERVICE] ===== CHECK QR STATUS DEBUG =====');
      print('[QR SERVICE] QR Code ID: $qrCodeId');
      print('[QR SERVICE] Card ID: $cardId');

      final requestData = {
        'qr_code_id': qrCodeId,
        'card_id': cardId,
      };

      print('[QR SERVICE] Request data: $requestData');
      print('[QR SERVICE] =================================');

      DebugLogger.apiRequest('/action/checkQrStatus', requestData);

      final response = await _dio.post(
        '/action/checkQrStatus',
        data: requestData,
      );

      DebugLogger.apiResponse('/action/checkQrStatus', response.data);

      if (response.data['success'] == true) {
        return QrStatusResponse.fromJson(response.data);
      } else {
        throw QrException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/action/checkQrStatus', e);

      if (e.response != null && e.response?.data != null) {
        throw QrException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw QrException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}

// QR Status Response Model
class QrStatusResponse {
  final bool success;
  final String message;
  final String? status;
  final Map<String, dynamic>? data;

  QrStatusResponse({
    required this.success,
    required this.message,
    this.status,
    this.data,
  });

  factory QrStatusResponse.fromJson(Map<String, dynamic> json) {
    return QrStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'],
      data: json['data'],
    );
  }
}

// QR Exception
class QrException implements Exception {
  final String message;
  QrException(this.message);

  @override
  String toString() => 'QrException: $message';
}
