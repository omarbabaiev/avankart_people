import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import '../models/membership_models.dart';
import 'auth_service.dart';

class MembershipService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  MembershipService() {
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

  // Get user's memberships with pagination
  Future<MembershipsResponse?> getMyMemberships({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      DebugLogger.apiRequest('/people/uzvluk', {
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/people/uzvluk',
        data: {
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/people/uzvluk', response.data);

      if (response.data['success'] == true) {
        return MembershipsResponse.fromJson(response.data);
      } else {
        throw MembershipException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/uzvluk', e);

      if (e.response != null && e.response?.data != null) {
        throw MembershipException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw MembershipException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Get membership details by company ID
  Future<MembershipDetailResponse?> getMembershipDetails({
    required String sirketId,
  }) async {
    try {
      DebugLogger.apiRequest('/people/uzvluk/$sirketId/details', {});

      final response = await _dio.get('/people/uzvluk/$sirketId/details');

      DebugLogger.apiResponse(
          '/people/uzvluk/$sirketId/details', response.data);

      if (response.data['success'] == true) {
        return MembershipDetailResponse.fromJson(response.data);
      } else {
        throw MembershipException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/uzvluk/$sirketId/details', e);

      if (e.response != null && e.response?.data != null) {
        throw MembershipException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw MembershipException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}

class MembershipException implements Exception {
  final String message;
  MembershipException(this.message);
  @override
  String toString() => message;
}
