import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constant/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/chat_models.dart';

abstract interface class ChatGateway {
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  });

  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  });
}

class ChatApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ChatApiException(
    this.message, {
    this.statusCode,
    this.code,
  });

  bool get canRetry {
    if (code == 'CHAT_IDEMPOTENCY_CONFLICT') return false;
    return statusCode == null ||
        statusCode == 409 ||
        statusCode == 429 ||
        statusCode == 503 ||
        (statusCode != null && statusCode! >= 500);
  }

  @override
  String toString() => message;
}

class ChatService implements ChatGateway {
  final Dio _dio;

  ChatService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  @override
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.chatPengukuran(pengukuranId),
        queryParameters: {
          'limit': limit,
          if (beforeId != null) 'before_id': beforeId,
        },
      );
      return ChatConversation.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw _toChatException(error);
    } on FormatException catch (error) {
      throw ChatApiException(
          'Respons percakapan tidak valid: ${error.message}');
    }
  }

  @override
  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatPengukuran(pengukuranId),
        data: {
          'client_message_id': clientMessageId,
          'message': message,
        },
      );
      return ChatExchange.fromJson(_responseData(response.data));
    } on DioException catch (error) {
      throw _toChatException(error);
    } on FormatException catch (error) {
      throw ChatApiException(
          'Respons percakapan tidak valid: ${error.message}');
    }
  }

  static Map<String, dynamic> _responseData(Object? body) {
    if (body is! Map || body['data'] is! Map) {
      throw const FormatException('data tidak tersedia');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  static ChatApiException _toChatException(DioException error) {
    final body = error.response?.data;
    final data = body is Map && body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : const <String, dynamic>{};
    final backendMessage = body is Map ? body['message']?.toString() : null;
    return ChatApiException(
      backendMessage ??
          error.error?.toString() ??
          error.message ??
          'Percakapan gagal dimuat, silakan coba lagi',
      statusCode: error.response?.statusCode,
      code: data['code']?.toString(),
    );
  }
}

typedef ChatMessageIdGenerator = String Function();

String generateChatMessageId() => const Uuid().v7();
