import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/models/reason_model.dart';
import 'package:dio/dio.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class QueryService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl + '/people',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  QueryService() {
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

  /// Get my tickets/support queries
  Future<Map<String, dynamic>> getMyTickets({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      DebugLogger.apiRequest('/sorgu', {
        'page': page,
        'limit': limit,
      });

      final response = await _dio.post(
        '/sorgu',
        data: {
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/sorgu', response.data);

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw QueryException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/sorgu', e);

      if (e.response != null && e.response?.data != null) {
        throw QueryException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw QueryException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Get ticket details
  Future<Map<String, dynamic>> getTicketDetails({
    required String ticketId,
  }) async {
    try {
      DebugLogger.apiRequest('/sorgu/inside', {
        'ticket_id': ticketId,
      });

      final response = await _dio.post(
        '/sorgu/inside',
        data: {
          'ticket_id': ticketId,
        },
      );

      DebugLogger.apiResponse('/sorgu/inside', response.data);

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw QueryException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/sorgu/inside', e);

      if (e.response != null && e.response?.data != null) {
        throw QueryException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw QueryException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Create new ticket
  Future<Map<String, dynamic>> createTicket({
    required String title,
    required String content,
    required String description,
    required String category,
    required List<String> reason,
    List<String>? files,
  }) async {
    try {
      DebugLogger.apiRequest('/sorgu/add', {
        'title': title,
        'content': content,
        'description': description,
        'category': category,
        'files': files,
        'reason': reason.join(','),
      });

      dio.FormData formData = dio.FormData.fromMap({
        'title': title,
        'content': content,
        'description': description,
        'category': category,
        'reason': reason.join(','),
        if (files != null && files.isNotEmpty)
          'files': files
              .map((file) => dio.MultipartFile.fromFileSync(file))
              .toList(),
      });

      final response = await _dio.post(
        '/sorgu/add',
        data: formData,
      );

      DebugLogger.apiResponse('/sorgu/add', response.data);

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw QueryException(ApiResponseParser.parseApiError(response.data));
      }
    } on DioException catch (e) {
      DebugLogger.apiError('/sorgu/add', e);

      if (e.response != null && e.response?.data != null) {
        throw QueryException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        throw QueryException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Get reasons grouped by category (general, account, pay)
  Future<ReasonsResponse> getReasons() async {
    try {
      DebugLogger.apiRequest('/sorgu/reasons', {});

      final response = await _dio.get('/sorgu/reasons');

      DebugLogger.apiResponse('/sorgu/reasons', response.data);

      // API response format'ını kontrol et
      print('[DEBUG] Reasons response: ${response.data}');

      // Eğer response sadece {status: ok} format'ındaysa, mock data döndür
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('status') && !data.containsKey('success')) {
          // API henüz implement edilmemiş, mock data döndür
          return ReasonsResponse(
            success: true,
            data: {
              'general': [
                ReasonModel(
                    id: '1',
                    name: 'Ümumi sual',
                    text: 'Ümumi məsələlər və suallar haqqında'),
                ReasonModel(
                    id: '2',
                    name: 'Şikayət',
                    text: 'Xidmət keyfiyyəti ilə bağlı şikayət'),
              ],
              'account': [
                ReasonModel(
                    id: '3',
                    name: 'Hesaba daxil ola bilmirəm',
                    text: 'Login və ya parol problemi'),
                ReasonModel(
                    id: '4',
                    name: 'Hesab bloklanıb',
                    text: 'Hesabım bloklanıb, açılmasını istəyirəm'),
              ],
              'pay': [
                ReasonModel(
                    id: '5',
                    name: 'Ödəniş edə bilmirəm',
                    text: 'Ödəniş zamanı xəta baş verir'),
                ReasonModel(
                    id: '6',
                    name: 'Pul geri qaytarılması',
                    text: 'Səhv ödənişin geri qaytarılması'),
              ],
            },
            message: 'Mock reasons data',
          );
        }
      }

      return ReasonsResponse.fromJson(response.data);
    } on DioException catch (e) {
      DebugLogger.apiError('/sorgu/reasons', e.response?.data ?? e.message);
      throw QueryException('Failed to load reasons: ${e.message}');
    } catch (e) {
      DebugLogger.apiError('/sorgu/reasons', e);
      throw QueryException('Error getting reasons: $e');
    }
  }
}

class QueryException implements Exception {
  final String message;
  QueryException(this.message);

  @override
  String toString() => 'QueryException: $message';
}
