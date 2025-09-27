import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import '../models/companies_response.dart';
import 'auth_service.dart';

class CompaniesService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  CompaniesService() {
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

  /// Get companies with filters and pagination
  Future<CompaniesResponse?> getCompanies({
    double? lat,
    double? lng,
    String? filterType,
    String? search,
    String? cardId,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      DebugLogger.apiRequest('/people/muessise', {
        'lat': lat,
        'lng': lng,
        'filterType': filterType,
        'search': search,
        'card_id': cardId,
        'muessise_category': muessiseCategory,
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/people/muessise',
        data: {
          'lat': lat,
          'lng': lng,
          'filterType': filterType,
          'search': search,
          'card_id': cardId,
          'muessise_category': muessiseCategory ?? [],
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/people/muessise', response.data);

      // Companies endpoint'i success field'ı kullanmıyor, direkt parse et
      if (response.data.containsKey('muessises') ||
          response.data.containsKey('data')) {
        return CompaniesResponse.fromJson(response.data);
      } else {
        throw CompaniesException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/muessise', e);

      if (e.response != null && e.response?.data != null) {
        throw CompaniesException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CompaniesException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Get companies on map with bounds
  Future<CompaniesResponse?> getCompaniesOnMap({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    try {
      DebugLogger.apiRequest('/people/get-on-map', {
        'northEast': {'lat': northEastLat, 'lng': northEastLng},
        'southWest': {'lat': southWestLat, 'lng': southWestLng},
      });

      final response = await _dio.post(
        '/people/get-on-map',
        data: {
          'northEast': {
            'lat': northEastLat,
            'lng': northEastLng,
          },
          'southWest': {
            'lat': southWestLat,
            'lng': southWestLng,
          },
        },
      );

      DebugLogger.apiResponse('/people/get-on-map', response.data);

      if (response.data['success'] == true) {
        return CompaniesResponse.fromJson(response.data);
      } else {
        throw CompaniesException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/get-on-map', e);

      if (e.response != null && e.response?.data != null) {
        throw CompaniesException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CompaniesException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Add company to favorites
  Future<Map<String, dynamic>> addToFavorites({
    required String muessiseId,
  }) async {
    try {
      DebugLogger.apiRequest('/people/favorites/muessise', {
        'muessise_id': muessiseId,
      });

      final response = await _dio.post(
        '/people/favorites/muessise',
        data: {
          'muessise_id': muessiseId,
        },
      );

      DebugLogger.apiResponse('/people/favorites/muessise', response.data);

      return response.data;
    } on DioException catch (e) {
      DebugLogger.apiError('/people/favorites/muessise', e);

      if (e.response != null && e.response?.data != null) {
        throw CompaniesException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CompaniesException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}
