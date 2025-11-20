import 'package:flutter/material.dart';

class MessageModel {
  final String id;
  final String from;
  final String fromModel;
  final String? to;
  final String toModel;
  final String message;
  final String status;
  final String ticketId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.from,
    required this.fromModel,
    this.to,
    required this.toModel,
    required this.message,
    required this.status,
    required this.ticketId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    try {
      return MessageModel(
        id: json['_id'] ?? '',
        from: json['from'] ?? '',
        fromModel: json['fromModel'] ?? '',
        to: json['to'],
        toModel: json['toModel'] ?? '',
        message: json['message'] ?? '',
        status: json['status'] ?? 'unread',
        ticketId: json['ticket_id'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('[ERROR] Failed to parse MessageModel: $e');
      debugPrint('[ERROR] JSON data: $json');
      // Default bir message döndür
      return MessageModel(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        from: 'unknown',
        fromModel: 'Unknown',
        toModel: 'Unknown',
        message: 'Parse error',
        status: 'error',
        ticketId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'fromModel': fromModel,
      'to': to,
      'toModel': toModel,
      'message': message,
      'status': status,
      'ticket_id': ticketId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isFromUser =>
      fromModel == 'PeopleUser' ||
      fromModel == 'peopleuser' ||
      fromModel == 'user';
  bool get isFromAdmin =>
      fromModel == 'AdminUser' ||
      fromModel == 'adminuser' ||
      fromModel == 'admin';
  bool get isRead => status == 'read';
}

class MessagesResponse {
  final bool success;
  final List<MessageModel> data;
  final String? message;

  MessagesResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    try {
      return MessagesResponse(
        success: json['success'] ?? false,
        data: (json['data'] as List<dynamic>?)
                ?.map((message) => MessageModel.fromJson(message))
                .toList() ??
            [],
        message: json['message'],
      );
    } catch (e) {
      debugPrint('[ERROR] Failed to parse MessagesResponse: $e');
      debugPrint('[ERROR] JSON data: $json');
      return MessagesResponse(
        success: false,
        data: [],
        message: 'Failed to parse response',
      );
    }
  }
}

class SendMessageRequest {
  final String message;
  final String ticketId;

  SendMessageRequest({
    required this.message,
    required this.ticketId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'ticket_id': ticketId,
    };
  }
}

class SendMessageResponse {
  final bool success;
  final String message;
  final MessageModel data;

  SendMessageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SendMessageResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: MessageModel.fromJson(json['data']),
      );
    } catch (e) {
      debugPrint('[ERROR] Failed to parse SendMessageResponse: $e');
      debugPrint('[ERROR] JSON data: $json');
      // Mock bir response döndür
      return SendMessageResponse(
        success: false,
        message: 'Failed to parse response',
        data: MessageModel(
          id: 'error',
          from: 'system',
          fromModel: 'System',
          toModel: 'User',
          message: 'Error occurred',
          status: 'error',
          ticketId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}
