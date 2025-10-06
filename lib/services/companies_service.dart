import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import '../models/companies_response.dart';
import '../models/companies_on_map_response.dart';
import '../models/company_detail_model.dart';
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
  Future<CompaniesOnMapResponse?> getCompaniesOnMap({
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
        return CompaniesOnMapResponse.fromJson(response.data);
      } else {
        throw CompaniesOnMapException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/get-on-map', e);

      if (e.response != null && e.response?.data != null) {
        throw CompaniesOnMapException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CompaniesOnMapException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Search companies
  Future<CompaniesResponse?> searchCompanies({
    required String query,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final requestData = {
        'lat': lat,
        'lng': lng,
        'filterType': 'name',
        'search': query,
        'card_id': null,
        'cards': [],
        'muessise_category': [],
        'page': page,
        'limit': limit,
      };

      DebugLogger.apiRequest('/people/muessise', requestData);

      final response = await _dio.post(
        '/people/muessise',
        data: requestData,
      );

      DebugLogger.apiResponse('/people/muessise', response.data);

      // Search API response formatını kontrol et
      // Eğer response'da muessises array'i varsa parse et
      if (response.data['muessises'] != null) {
        return CompaniesResponse.fromJson(response.data);
      } else {
        // Eğer muessises array'i yoksa boş response döndür
        return CompaniesResponse(
          page: 1,
          limit: limit,
          total: 0,
          muessises: [],
        );
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

  /// Get company details
  Future<CompanyDetailResponse?> getCompanyDetails({
    required String muessiseId,
    double? lat,
    double? lng,
  }) async {
    try {
      DebugLogger.apiRequest('/people/muessise/details', {
        'muessise_id': muessiseId,
        'lat': lat,
        'lng': lng,
      });

      final response = await _dio.post(
        '/people/muessise/details',
        data: {
          'lat': lat,
          'lng': lng,
          'muessise_id': muessiseId,
        },
      );

      DebugLogger.apiResponse('/people/muessise/details', response.data);

      if (response.data['success'] == true) {
        return CompanyDetailResponse.fromJson(response.data);
      } else {
        throw CompaniesException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/muessise/details', e);

      if (e.response != null && e.response?.data != null) {
        throw CompaniesException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CompaniesException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Get favorite companies
  Future<CompaniesResponse?> getFavoriteCompanies({
    double? lat,
    double? lng,
    String? filterType,
    String? search,
    List<String>? cards,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      DebugLogger.apiRequest('/people/muessise/favorites', {
        'lat': lat,
        'lng': lng,
        'filterType': filterType,
        'search': search,
        'cards': cards,
        'muessise_category': muessiseCategory,
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/people/muessise/favorites',
        data: {
          'lat': lat,
          'lng': lng,
          'filterType': filterType ?? 'name',
          'search': search,
          'cards': cards ?? [],
          'muessise_category': muessiseCategory ?? [],
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/people/muessise/favorites', response.data);

      if (response.data['success'] == true) {
        return CompaniesResponse.fromJson(response.data);
      } else {
        throw CompaniesException(
            ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/muessise/favorites', e);

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
