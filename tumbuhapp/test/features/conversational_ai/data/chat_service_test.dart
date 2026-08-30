import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/conversational_ai/data/chat_service.dart';
import 'package:tumbuhapp/features/conversational_ai/models/chat_models.dart';

class _JsonAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> body;
  RequestOptions? request;

  _JsonAdapter({required this.statusCode, required this.body});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_JsonAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'))
    ..httpClientAdapter = adapter;
}

Map<String, dynamic> _message({
  required int id,
  required String role,
  String? clientMessageId,
  int? replyToMessageId,
  String? responseType,
}) {
  return {
    'id': id,
    'client_message_id': clientMessageId,
    'reply_to_message_id': replyToMessageId,
    'role': role,
    'content': role == 'orang_tua' ? 'Apa contoh protein?' : 'Telur dan tempe.',
    'response_type': responseType,
    'created_at': '2026-08-29T08:00:00.000Z',
  };
}

void main() {
  test('history membaca status, pesan, dan cursor pagination', () async {
    final adapter = _JsonAdapter(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'pengukuran_id': 12,
          'is_active': true,
          'insight_status': 'completed',
          'insight_teks': 'Insight awal',
          'messages': [
            _message(
              id: 31,
              role: 'orang_tua',
              clientMessageId: '018f0000-0000-4000-8000-000000000001',
            ),
            _message(
              id: 32,
              role: 'assistant',
              replyToMessageId: 31,
              responseType: 'answered',
            ),
          ],
          'pagination': {'has_more': true, 'next_before_id': 31},
        },
      },
    );
    final service = ChatService(dio: _dio(adapter));

    final result = await service.getHistory(12, limit: 20, beforeId: 50);

    expect(adapter.request?.path, '/orang-tua/pengukuran/12/chat');
    expect(adapter.request?.queryParameters, {
      'limit': 20,
      'before_id': 50,
    });
    expect(result.canSend, isTrue);
    expect(result.messages, hasLength(2));
    expect(result.messages.last.role, ChatRole.assistant);
    expect(result.messages.last.responseType, ChatResponseType.answered);
    expect(result.nextBeforeId, 31);
  });

  test('send meneruskan UUID dan membaca pasangan pesan idempotent', () async {
    const clientMessageId = '018f0000-0000-4000-8000-000000000001';
    final adapter = _JsonAdapter(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'user_message': _message(
            id: 31,
            role: 'orang_tua',
            clientMessageId: clientMessageId,
          ),
          'assistant_message': _message(
            id: 32,
            role: 'assistant',
            replyToMessageId: 31,
            responseType: 'answered',
          ),
          'idempotent': true,
        },
      },
    );
    final service = ChatService(dio: _dio(adapter));

    final result = await service.sendMessage(
      pengukuranId: 12,
      clientMessageId: clientMessageId,
      message: 'Apa contoh protein?',
    );

    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.data, {
      'client_message_id': clientMessageId,
      'message': 'Apa contoh protein?',
    });
    expect(result.idempotent, isTrue);
    expect(result.assistantMessage.replyToMessageId, 31);
  });

  test('error PII mempertahankan status, kode, dan pesan backend', () async {
    final adapter = _JsonAdapter(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'Hapus data pribadi dari pertanyaan',
        'data': {'code': 'CHAT_PII_DETECTED'},
      },
    );
    final service = ChatService(dio: _dio(adapter));

    await expectLater(
      service.sendMessage(
        pengukuranId: 12,
        clientMessageId: '018f0000-0000-4000-8000-000000000001',
        message: 'Pesan privat',
      ),
      throwsA(
        isA<ChatApiException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having((error) => error.code, 'code', 'CHAT_PII_DETECTED')
            .having(
              (error) => error.message,
              'message',
              'Hapus data pribadi dari pertanyaan',
            )
            .having((error) => error.canRetry, 'canRetry', isFalse),
      ),
    );
  });

  test('generator membuat UUID v7 dengan timestamp dan variant RFC', () {
    final before = DateTime.now().millisecondsSinceEpoch;
    final first = generateChatMessageId();
    final second = generateChatMessageId();
    final after = DateTime.now().millisecondsSinceEpoch;
    final uuidV7 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(first, matches(uuidV7));
    expect(second, matches(uuidV7));
    expect(second, isNot(first));

    final timestamp = int.parse(
      first.replaceAll('-', '').substring(0, 12),
      radix: 16,
    );
    expect(timestamp, inInclusiveRange(before, after));
  });

  test('konflik UUID bersifat terminal sedangkan processing dapat di-retry',
      () {
    const conflict = ChatApiException(
      'UUID sudah digunakan',
      statusCode: 409,
      code: 'CHAT_IDEMPOTENCY_CONFLICT',
    );
    const processing = ChatApiException(
      'Pesan sedang diproses',
      statusCode: 409,
      code: 'CHAT_REQUEST_PROCESSING',
    );

    expect(conflict.canRetry, isFalse);
    expect(processing.canRetry, isTrue);
  });
}
