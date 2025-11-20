import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import 'auth_service.dart';

class PinService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  PinService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: SecureStorageConfig.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // POST /people/profile/pin/check { pin_code }
  Future<bool> checkPin({required String pinCode}) async {
    try {
      DebugLogger.apiRequest('/people/profile/pin/check', {'pin_code': pinCode});
      final response = await _dio.post(
        '/people/profile/pin/check',
        data: {'pin_code': pinCode},
      );
      DebugLogger.apiResponse('/people/profile/pin/check', response.data);
      // Başarı durumları:
      // 1) { success: true, ... }
      // 2) 200 ve { message: "PIN verified successfully" }
      final data = response.data;
      if (data is Map) {
        if (data['success'] == true) return true;
        final msg = (data['message'] ?? data['msg'] ?? '').toString().toLowerCase().trim();
        if (msg == 'pin verified successfully') return true;
      }
      // Bazı backend'ler sadece 200 dönebilir
      if (response.statusCode == 200) {
        return true;
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/check', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // POST /people/profile/pin/create-update { new_pin, old_pin? }
  Future<bool> createOrUpdatePin({
    required String newPin,
    String? oldPin,
  }) async {
    try {
      final data = <String, dynamic>{'new_pin': newPin};
      if (oldPin != null && oldPin.isNotEmpty) data['old_pin'] = oldPin;
      DebugLogger.apiRequest('/people/profile/pin/create-update', data);
      final response = await _dio.post(
        '/people/profile/pin/create-update',
        data: data,
      );
      DebugLogger.apiResponse('/people/profile/pin/create-update', response.data);
      if (response.data['success'] == true || response.statusCode == 200) {
        return true;
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/create-update', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // POST /people/profile/pin/status { status: bool, new_pin? }
  Future<bool> setPinStatus({
    required bool status,
    String? newPin,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (newPin != null && newPin.isNotEmpty) data['new_pin'] = newPin;
      DebugLogger.apiRequest('/people/profile/pin/status', data);
      final response = await _dio.post(
        '/people/profile/pin/status',
        data: data,
      );
      DebugLogger.apiResponse('/people/profile/pin/status', response.data);
      if (response.data['success'] == true || response.statusCode == 200) {
        return true;
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/status', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // POST /people/profile/pin/forgot
  Future<bool> forgotPin() async {
    try {
      DebugLogger.apiRequest('/people/profile/pin/forgot', {});
      final response = await _dio.post('/people/profile/pin/forgot');
      DebugLogger.apiResponse('/people/profile/pin/forgot', response.data);
      if (response.data['success'] == true || response.statusCode == 200) {
        return true;
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/forgot', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // POST /people/profile/pin/submit-otp { otp }
  // Returns response map including token when successful
  Future<Map<String, dynamic>> submitOtp({required String otp}) async {
    try {
      DebugLogger.apiRequest('/people/profile/pin/submit-otp', {'otp': otp});
      final response = await _dio.post(
        '/people/profile/pin/submit-otp',
        data: {'otp': otp},
      );
      DebugLogger.apiResponse('/people/profile/pin/submit-otp', response.data);
      if (response.data is Map &&
          (response.data['success'] == true || response.statusCode == 200)) {
        return Map<String, dynamic>.from(response.data);
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/submit-otp', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // POST /people/profile/pin/change { new_pin, token }
  Future<bool> changePinWithToken({
    required String newPin,
    required String token,
  }) async {
    try {
      final data = {'new_pin': newPin, 'token': token};
      DebugLogger.apiRequest('/people/profile/pin/change', data);
      final response = await _dio.post(
        '/people/profile/pin/change',
        data: data,
      );
      DebugLogger.apiResponse('/people/profile/pin/change', response.data);
      if (response.data['success'] == true || response.statusCode == 200) {
        return true;
      }
      throw PinException(ApiResponseParser.parseApiError(response.data));
    } on DioException catch (e) {
      DebugLogger.apiError('/people/profile/pin/change', e);
      if (e.response != null && e.response?.data != null) {
        throw PinException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw PinException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}

class PinException implements Exception {
  final String message;
  PinException(this.message);
  @override
  String toString() => message;
}


