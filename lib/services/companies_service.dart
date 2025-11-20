import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import '../utils/auth_utils.dart';
import '../models/companies_response.dart';
import '../models/companies_on_map_response.dart';
import '../models/company_detail_model.dart';
import '../models/favorite_toggle_response.dart';
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

  /// Unauthorized hata kontrolü
  bool _isUnauthorizedError(DioException e) {
    return e.response?.statusCode == 401 ||
        (e.response?.data != null &&
            e.response?.data['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('unauthorized') ==
                true) ||
        (e.response?.data != null &&
            e.response?.data['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('token') ==
                true);
  }

  /// Get companies with filters and pagination
  Future<CompaniesResponse?> getCompanies({
    double? lat,
    double? lng,
    String? filterType,
    String? search,
    String? cardId,
    List<String>? cards,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Collection'a göre cards array olarak gönderilmeli
      final cardsList = cards ?? (cardId != null ? [cardId] : []);
      
      DebugLogger.apiRequest('/people/muessise', {
        'lat': lat,
        'lng': lng,
        'filterType': filterType,
        'search': search,
        'cards': cardsList,
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
          'cards': cardsList,
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

      // Unauthorized hata kontrolü
      if (_isUnauthorizedError(e)) {
        debugPrint(
            '[COMPANIES SERVICE] Unauthorized error detected, forcing logout');
        await AuthUtils.forceLogout();
        throw CompaniesException('auth.session_expired'.tr);
      }

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
    List<String>? cards,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final requestData = {
        'lat': lat,
        'lng': lng,
        'filterType': 'name',
        'search': query,
        'cards': cards ?? [],
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

      // Unauthorized hata kontrolü
      if (_isUnauthorizedError(e)) {
        debugPrint(
            '[COMPANIES SERVICE] Unauthorized error detected in search, forcing logout');
        await AuthUtils.forceLogout();
        throw CompaniesException('auth.session_expired'.tr);
      }

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
    int limit = 20,
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

  /// Toggle favorite status for a company (add/remove)
  Future<FavoriteToggleResponse?> toggleFavorite({
    required String muessiseId,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('[FAVORITES SERVICE] 🔄 Toggle Favorite Request');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint(
          '[FAVORITES SERVICE] 📍 Endpoint: POST /people/favorites/muessise');
      debugPrint('[FAVORITES SERVICE] 📤 Request Body:');
      debugPrint('[FAVORITES SERVICE]   - muessise_id: $muessiseId');
      debugPrint('[FAVORITES SERVICE] ⏱️  Request Time: ${DateTime.now()}');

      DebugLogger.apiRequest('/people/favorites/muessise', {
        'muessise_id': muessiseId,
      });

      final response = await _dio.post(
        '/people/favorites/muessise',
        data: {
          'muessise_id': muessiseId,
        },
      );

      debugPrint('───────────────────────────────────────────────────');
      debugPrint('[FAVORITES SERVICE] 📥 Response Received');
      debugPrint('───────────────────────────────────────────────────');
      debugPrint('[FAVORITES SERVICE] ✅ Status Code: ${response.statusCode}');
      debugPrint('[FAVORITES SERVICE] 📦 Full Response Data:');
      debugPrint('[FAVORITES SERVICE]   RAW: ${response.data}');
      debugPrint('[FAVORITES SERVICE] 📦 Parsed Fields:');
      debugPrint('[FAVORITES SERVICE]   - status: ${response.data['status']}');
      debugPrint(
          '[FAVORITES SERVICE]   - message: ${response.data['message']}');
      debugPrint(
          '[FAVORITES SERVICE] 📋 All Keys: ${response.data.keys.toList()}');
      debugPrint('[FAVORITES SERVICE] ⏱️  Response Time: ${DateTime.now()}');
      debugPrint('═══════════════════════════════════════════════════');

      DebugLogger.apiResponse('/people/favorites/muessise', response.data);

      final parsedResponse = FavoriteToggleResponse.fromJson(response.data);
      debugPrint('[FAVORITES SERVICE] 🔍 Parsed Response:');
      debugPrint('[FAVORITES SERVICE]   - isAdded: ${parsedResponse.isAdded}');
      debugPrint(
          '[FAVORITES SERVICE]   - isRemoved: ${parsedResponse.isRemoved}');
      debugPrint('[FAVORITES SERVICE]   - isValid: ${parsedResponse.isValid}');

      return parsedResponse;
    } on DioException catch (e) {
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('[FAVORITES SERVICE] ❌ Request Failed');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('[FAVORITES SERVICE] 🚫 Error Type: ${e.type}');
      debugPrint('[FAVORITES SERVICE] 💬 Error Message: ${e.message}');
      if (e.response != null) {
        debugPrint('[FAVORITES SERVICE] 📥 Error Response:');
        debugPrint(
            '[FAVORITES SERVICE]   - Status Code: ${e.response?.statusCode}');
        debugPrint(
            '[FAVORITES SERVICE]   - Response Data: ${e.response?.data}');
      }
      debugPrint('═══════════════════════════════════════════════════');

      DebugLogger.apiError('/people/favorites/muessise', e);

      if (e.response != null && e.response?.data != null) {
        throw FavoriteToggleException(
            ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw FavoriteToggleException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}
