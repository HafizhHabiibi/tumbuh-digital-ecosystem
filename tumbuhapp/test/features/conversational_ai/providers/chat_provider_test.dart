import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/conversational_ai/data/chat_service.dart';
import 'package:tumbuhapp/features/conversational_ai/models/chat_models.dart';
import 'package:tumbuhapp/features/conversational_ai/providers/chat_provider.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';

ChatMessage _message(int id, ChatRole role) {
  return ChatMessage(
    id: id,
    clientMessageId: role == ChatRole.orangTua ? 'client-$id' : null,
    replyToMessageId: role == ChatRole.assistant ? id - 1 : null,
    role: role,
    content: role == ChatRole.orangTua ? 'Pertanyaan' : 'Jawaban',
    responseType: role == ChatRole.assistant ? ChatResponseType.answered : null,
    createdAt: DateTime.utc(2026, 8, 29),
  );
}

ChatConversation _conversation({
  List<ChatMessage> messages = const [],
  bool hasMore = false,
  int? nextBeforeId,
}) {
  return ChatConversation(
    pengukuranId: 12,
    isActive: true,
    insightStatus: InsightStatus.completed,
    insightText: 'Insight awal',
    messages: messages,
    pagination: ChatPagination(
      hasMore: hasMore,
      nextBeforeId: nextBeforeId,
    ),
  );
}

class _FakeGateway implements ChatGateway {
  ChatConversation history = _conversation();
  ChatExchange? result;
  ChatApiException? nextError;
  final List<String> sentIds = [];
  final List<int?> cursors = [];

  @override
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  }) async {
    cursors.add(beforeId);
    return history;
  }

  @override
  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  }) async {
    sentIds.add(clientMessageId);
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
    return result!;
  }
}

void main() {
  test(
      'retry jaringan menggunakan UUID yang sama lalu menambahkan satu exchange',
      () async {
    final gateway = _FakeGateway()
      ..result = ChatExchange(
        userMessage: _message(31, ChatRole.orangTua),
        assistantMessage: _message(32, ChatRole.assistant),
        idempotent: false,
      )
      ..nextError = const ChatApiException(
        'Provider sementara tidak tersedia',
        statusCode: 503,
      );
    final controller = ChatController(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-tetap',
    );

    await controller.load();
    await controller.sendMessage('Apa contoh protein?');

    expect(controller.state.pendingMessage?.clientMessageId, 'uuid-tetap');
    expect(controller.state.errorMessage, isNotNull);
    expect(controller.state.canSend, isFalse);

    await controller.retryPending();

    expect(gateway.sentIds, ['uuid-tetap', 'uuid-tetap']);
    expect(controller.state.pendingMessage, isNull);
    expect(controller.state.conversation?.messages, hasLength(2));
  });

  test('penolakan PII bersifat terminal dan meneruskan kode untuk UI',
      () async {
    final gateway = _FakeGateway()
      ..nextError = const ChatApiException(
        'Hapus data pribadi dari pertanyaan',
        statusCode: 400,
        code: 'CHAT_PII_DETECTED',
      );
    final controller = ChatController(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-pii',
    );

    await controller.load();
    await controller.sendMessage('Pesan dengan data pribadi');

    expect(controller.state.errorCode, 'CHAT_PII_DETECTED');
    expect(controller.state.pendingMessage, isNull);
    await controller.retryPending();
    expect(gateway.sentIds, ['uuid-pii']);
  });

  test('pagination menaruh pesan lama di depan tanpa duplikasi', () async {
    final gateway = _FakeGateway()
      ..history = _conversation(
        messages: [_message(31, ChatRole.orangTua)],
        hasMore: true,
        nextBeforeId: 31,
      );
    final controller = ChatController(pengukuranId: 12, gateway: gateway);

    await controller.load();
    gateway.history = _conversation(
      messages: [
        _message(29, ChatRole.orangTua),
        _message(30, ChatRole.assistant),
        _message(31, ChatRole.orangTua),
      ],
    );
    await controller.loadOlder();

    expect(gateway.cursors, [null, 31]);
    expect(
      controller.state.conversation?.messages.map((message) => message.id),
      [29, 30, 31],
    );
  });
}
