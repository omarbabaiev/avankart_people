import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:avankart_people/models/message_model.dart';
import 'package:avankart_people/utils/conts_texts.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:flutter/material.dart';

class QueryChatService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ConstTexts.baseUrl + '/people',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  QueryChatService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Bearer token authentication [[memory:6819814]]
        final token = await _storage.read(key: SecureStorageConfig.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Ticket mesajlarını getir (pagination ile)
  Future<MessagesResponse> getTicketMessages({
    required String ticketId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      DebugLogger.apiRequest('/messages/$ticketId', {
        'page': page,
        'limit': limit,
      });

      final response = await _dio.get(
        '/messages/$ticketId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      DebugLogger.apiResponse('/messages/$ticketId', response.data);

      // API response format'ını kontrol et
      debugPrint('[DEBUG] Raw response: ${response.data}');
      debugPrint('[DEBUG] Response type: ${response.data.runtimeType}');

      // Eğer response sadece {status: ok} format'ındaysa, boş data döndür
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('status') && !data.containsKey('success')) {
          // API henüz implement edilmemiş, boş response döndür
          return MessagesResponse(
            success: true,
            data: [],
            message: 'No messages found',
          );
        }
      }

      return MessagesResponse.fromJson(response.data);
    } on DioException catch (e) {
      DebugLogger.apiError(
          '/messages/$ticketId', e.response?.data ?? e.message);
      throw Exception('Failed to load messages: ${e.message}');
    } catch (e) {
      DebugLogger.apiError('/messages/$ticketId', e);
      throw Exception('Error getting messages: $e');
    }
  }

  /// Yeni mesaj gönder
  Future<SendMessageResponse> sendMessage({
    required String message,
    required String ticketId,
  }) async {
    try {
      final request = SendMessageRequest(
        message: message,
        ticketId: ticketId,
      );

      DebugLogger.apiRequest('/messages/send', {
        'message': message,
        'ticket_id': ticketId,
      });

      final response = await _dio.post(
        '/messages/send',
        data: request.toJson(),
      );

      DebugLogger.apiResponse('/messages/send', response.data);

      // API response format'ını kontrol et
      debugPrint('[DEBUG] Send response: ${response.data}');

      // Eğer response sadece {status: ok} format'ındaysa, mock response döndür
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('status') && !data.containsKey('success')) {
          // API henüz implement edilmemiş, mock response döndür
          final mockMessage = MessageModel(
            id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
            from: 'current_user',
            fromModel: 'PeopleUser',
            toModel: 'AdminUser',
            message: message,
            status: 'sent',
            ticketId: ticketId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return SendMessageResponse(
            success: true,
            message: 'Message sent successfully',
            data: mockMessage,
          );
        }
      }

      return SendMessageResponse.fromJson(response.data);
    } on DioException catch (e) {
      DebugLogger.apiError('/messages/send', e.response?.data ?? e.message);
      if (e.response?.data != null) {
        throw Exception(
            e.response!.data['message'] ?? 'Failed to send message');
      }
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      DebugLogger.apiError('/messages/send', e);
      throw Exception('Error sending message: $e');
    }
  }

  /// Tüm mesajları getir (pagination olmadan)
  Future<List<MessageModel>> getAllMessages(String ticketId) async {
    try {
      List<MessageModel> allMessages = [];
      int page = 1;
      int limit = 10000;
      bool hasMore = true;

      while (hasMore) {
        final response = await getTicketMessages(
          ticketId: ticketId,
          page: page,
          limit: limit,
        );

        allMessages.addAll(response.data);

        // Eğer dönen mesaj sayısı limit'ten azsa, daha fazla mesaj yok demektir
        hasMore = response.data.length == limit;
        page++;
      }

      // Mesajları tarihe göre sırala (eskiden yeniye)
      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return allMessages;
    } catch (e) {
      throw Exception('Error getting all messages: $e');
    }
  }

  /// Mesaj durumunu güncelle (opsiyonel)
  Future<void> markMessageAsRead(String messageId) async {
    try {
      DebugLogger.apiRequest('/messages/$messageId/read', {});

      final response = await _dio.patch('/messages/$messageId/read');

      DebugLogger.apiResponse('/messages/$messageId/read', response.data);
    } on DioException catch (e) {
      DebugLogger.apiError(
          '/messages/$messageId/read', e.response?.data ?? e.message);
      throw Exception('Failed to mark message as read: ${e.message}');
    } catch (e) {
      DebugLogger.apiError('/messages/$messageId/read', e);
      throw Exception('Error marking message as read: $e');
    }
  }
}
