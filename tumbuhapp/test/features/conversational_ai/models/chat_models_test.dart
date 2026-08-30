import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/conversational_ai/models/chat_models.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';

Map<String, dynamic> _message(int id, String role) => {
      'id': id,
      'client_message_id': role == 'orang_tua' ? 'client-$id' : null,
      'reply_to_message_id': role == 'assistant' ? id - 1 : null,
      'role': role,
      'content': role == 'orang_tua' ? 'Pertanyaan' : 'Jawaban',
      'response_type': role == 'assistant' ? 'answered' : null,
      'created_at': '2026-08-30T08:00:00.000Z',
    };

void main() {
  test('conversation membentuk pagination dan status insight bertipe kuat', () {
    final conversation = ChatConversation.fromJson({
      'pengukuran_id': 12,
      'latest_pengukuran_id': 12,
      'is_active': true,
      'insight_status': 'completed',
      'insight_teks': 'Insight awal',
      'messages': [_message(31, 'orang_tua'), _message(32, 'assistant')],
      'pagination': {'has_more': true, 'next_before_id': 31},
    });

    expect(conversation.insightStatus, InsightStatus.completed);
    expect(conversation.latestPengukuranId, 12);
    expect(conversation.pagination.hasMore, isTrue);
    expect(conversation.pagination.nextBeforeId, 31);
    expect(conversation.canSend, isTrue);
  });

  test('exchange membaca pasangan pesan dan idempotency flag', () {
    final exchange = ChatExchange.fromJson({
      'user_message': _message(31, 'orang_tua'),
      'assistant_message': _message(32, 'assistant'),
      'idempotent': true,
    });

    expect(exchange.userMessage.role, ChatRole.orangTua);
    expect(exchange.assistantMessage.role, ChatRole.assistant);
    expect(exchange.assistantMessage.responseType, ChatResponseType.answered);
    expect(exchange.idempotent, isTrue);
  });

  test(
      'pesan backend berstatus sent dan dapat menjadi failed untuk state lokal',
      () {
    final message = ChatMessage.fromJson(_message(31, 'orang_tua'));

    expect(message.sendStatus, ChatSendStatus.sent);
    expect(
      message.copyWith(sendStatus: ChatSendStatus.failed).sendStatus,
      ChatSendStatus.failed,
    );
  });

  test('status insight dan response type tidak dikenal ditolak', () {
    expect(
      () => ChatConversation.fromJson({
        'pengukuran_id': 12,
        'latest_pengukuran_id': 12,
        'is_active': true,
        'insight_status': 'unknown',
        'messages': const [],
        'pagination': {'has_more': false, 'next_before_id': null},
      }),
      throwsFormatException,
    );
    expect(
      () => ChatMessage.fromJson({
        ..._message(32, 'assistant'),
        'response_type': 'unknown',
      }),
      throwsFormatException,
    );
  });
}
