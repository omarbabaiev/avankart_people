import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../utils/debug_logger.dart';
import '../utils/secure_storage_config.dart';
import '../models/card_models.dart';
import 'auth_service.dart';

class CardsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  CardsService() {
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

  // Get user's cards
  Future<CardsResponse?> getMyCards({String? sirketId}) async {
    try {
      debugPrint('[CARDS SERVICE] ===== GET MY CARDS DEBUG =====');
      debugPrint('[CARDS SERVICE] Received sirketId: $sirketId');

      final requestData = <String, dynamic>{};
      if (sirketId != null && sirketId.isNotEmpty) {
        requestData['sirket_id'] = sirketId;
        debugPrint('[CARDS SERVICE] Added sirket_id to request: $sirketId');
      } else {
        debugPrint(
            '[CARDS SERVICE] No sirket_id provided, sending empty request');
      }

      debugPrint('[CARDS SERVICE] Final request data: $requestData');
      debugPrint('[CARDS SERVICE] ===============================');

      DebugLogger.apiRequest('/people/cards/my-cards', requestData);

      final response = await _dio.post(
        '/people/cards/my-cards',
        data: requestData,
      );

      DebugLogger.apiResponse('/people/cards/my-cards', response.data);

      if (response.data['success'] == true) {
        return CardsResponse.fromJson(response.data);
      } else {
        throw CardsException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/cards/my-cards', e);

      // 404 hatası durumunda özel mesaj
      if (e.response?.statusCode == 404) {
        throw CardsException('user_not_found');
      }

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Get all cards with pagination
  Future<CardsResponse?> getAllCards({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      DebugLogger.apiRequest('/people/cards/get-all-cards', {
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/people/cards/get-all-cards',
        data: {
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/people/cards/get-all-cards', response.data);

      if (response.data['success'] == true) {
        return CardsResponse.fromJson(response.data);
      } else {
        throw CardsException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/cards/get-all-cards', e);

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Get card transactions
  Future<CardTransactionsResponse?> getCardTransactions({
    required String cardId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('[CARDS SERVICE] ===== GET CARD TRANSACTIONS DEBUG =====');
      debugPrint('[CARDS SERVICE] Card ID: $cardId');
      debugPrint('[CARDS SERVICE] Page: $page, Limit: $limit');
      debugPrint('[CARDS SERVICE] ======================================');

      DebugLogger.apiRequest('/people/cards/transactions', {
        'card_id': cardId,
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/people/cards/transactions',
        data: {
          'card_id': cardId,
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/people/cards/transactions', response.data);

      if (response.data['success'] == true) {
        return CardTransactionsResponse.fromJson(response.data);
      } else {
        throw CardsException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/cards/transactions', e);

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Get card transaction details
  Future<CardTransactionDetailsResponse?> getCardTransactionDetails({
    required String transactionId,
    String category = 'transaction',
  }) async {
    try {
      DebugLogger.apiRequest('/people/cards/transaction-details', {
        'transaction_id': transactionId,
        'category': category,
      });

      final response = await _dio.post(
        '/people/cards/transaction-details',
        data: {
          'transaction_id': transactionId,
          'category': category,
        },
      );

      DebugLogger.apiResponse(
          '/people/cards/transaction-details', response.data);

      if (response.data['success'] == true) {
        return CardTransactionDetailsResponse.fromJson(response.data);
      } else {
        throw CardsException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/cards/transaction-details', e);

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Get cards for filter
  Future<CardFilterResponse?> getCardsForFilter() async {
    try {
      DebugLogger.apiRequest('people/muessise/cards', {});

      final response = await _dio.get(
        '/people/muessise/cards',
      );

      DebugLogger.apiResponse('people/muessise/cards', response.data);

      // API {success: true, data: [...]} formatında dönüyor
      if (response.data['success'] == true) {
        return CardFilterResponse.fromJson(response.data);
      } else {
        throw CardsException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('people/muessise/cards', e);

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  // Request change card status
  Future<Map<String, dynamic>?> requestChangeCardStatus({
    required String cardId,
    required String status,
    List<String>? reasonIds,
  }) async {
    try {
      DebugLogger.apiRequest('/people/mycards/request-change-status', {
        'card_id': cardId,
        'status': status,
        'reason_id': reasonIds,
      });

      final response = await _dio.post(
        '/people/mycards/request-change-status',
        data: {
          'card_id': cardId,
          'status': status,
          'reason_id': reasonIds ?? [],
        },
      );

      DebugLogger.apiResponse(
          '/people/mycards/request-change-status', response.data);

      if (response.data != null) {
        return response.data;
      } else {
        throw CardsException('Invalid response from server');
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/people/mycards/request-change-status', e);

      if (e.response != null && e.response?.data != null) {
        throw CardsException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw CardsException('network_error'.tr + ': ${e.message}');
      }
    }
  }
}

class CardsException implements Exception {
  final String message;
  CardsException(this.message);
  @override
  String toString() => message;
}
