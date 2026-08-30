import 'dart:async';

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
  bool isActive = true,
  InsightStatus insightStatus = InsightStatus.completed,
}) {
  return ChatConversation(
    pengukuranId: 12,
    latestPengukuranId: 12,
    isActive: isActive,
    insightStatus: insightStatus,
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
  Completer<ChatExchange>? sendCompleter;
  Completer<ChatConversation>? historyCompleter;
  final List<String> sentIds = [];
  final List<String> sentMessages = [];
  final List<int?> cursors = [];
  final List<ChatConversation> historySequence = [];

  @override
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  }) async {
    cursors.add(beforeId);
    final completer = historyCompleter;
    if (completer != null) return completer.future;
    if (historySequence.isNotEmpty) return historySequence.removeAt(0);
    return history;
  }

  @override
  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  }) async {
    sentIds.add(clientMessageId);
    sentMessages.add(message);
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
    final completer = sendCompleter;
    if (completer != null) return completer.future;
    return result!;
  }
}

void main() {
  test('memuat conversation awal dan menyimpan draft', () async {
    final gateway = _FakeGateway()
      ..history = _conversation(
        messages: [_message(21, ChatRole.orangTua)],
      );
    final notifier = ChatNotifier(pengukuranId: 12, gateway: gateway);

    notifier.updateDraft('Apa arti hasil ini?');
    await notifier.load();

    expect(notifier.state.draft, 'Apa arti hasil ini?');
    expect(notifier.state.conversation?.messages, hasLength(1));
    expect(notifier.state.isActiveMode, isTrue);
    expect(notifier.state.isReadOnly, isFalse);
    expect(gateway.cursors, [null]);
  });

  test('membuat optimistic bubble lalu menggantinya dengan exchange backend',
      () async {
    final completer = Completer<ChatExchange>();
    final gateway = _FakeGateway()..sendCompleter = completer;
    final notifier = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-optimistic',
    );
    await notifier.load();
    notifier.updateDraft('Apa contoh protein?');

    final send = notifier.sendDraft();

    final optimistic = notifier.state.conversation!.messages.single;
    expect(optimistic.id, -1);
    expect(optimistic.clientMessageId, 'uuid-optimistic');
    expect(optimistic.sendStatus, ChatSendStatus.sending);
    expect(notifier.state.draft, isEmpty);
    expect(notifier.state.isSending, isTrue);

    completer.complete(
      ChatExchange(
        userMessage: _message(31, ChatRole.orangTua),
        assistantMessage: _message(32, ChatRole.assistant),
        idempotent: false,
      ),
    );
    await send;

    expect(
      notifier.state.conversation?.messages.map((message) => message.id),
      [31, 32],
    );
    expect(
      notifier.state.conversation?.messages
          .every((message) => message.sendStatus == ChatSendStatus.sent),
      isTrue,
    );
    expect(notifier.state.pendingMessage, isNull);
    expect(notifier.state.isSending, isFalse);
  });

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
    final controller = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-tetap',
    );

    await controller.load();
    await controller.sendMessage('Apa contoh protein?');

    expect(controller.state.pendingMessage?.clientMessageId, 'uuid-tetap');
    expect(controller.state.errorMessage, isNotNull);
    expect(controller.state.canSend, isFalse);
    expect(
      controller.state.conversation?.messages.single.sendStatus,
      ChatSendStatus.failed,
    );

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
    final controller = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-pii',
    );

    await controller.load();
    await controller.sendMessage('Pesan dengan data pribadi');

    expect(controller.state.errorCode, 'CHAT_PII_DETECTED');
    expect(controller.state.pendingMessage, isNull);
    expect(controller.state.canSend, isTrue);
    expect(
      controller.state.conversation?.messages.single.sendStatus,
      ChatSendStatus.failed,
    );
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
    final controller = ChatNotifier(pengukuranId: 12, gateway: gateway);

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

  test('mencegah double tap selama request masih aktif', () async {
    final completer = Completer<ChatExchange>();
    final gateway = _FakeGateway()..sendCompleter = completer;
    var generatedIds = 0;
    final notifier = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-${++generatedIds}',
    );
    await notifier.load();

    final firstSend = notifier.sendMessage('Pesan pertama');
    await notifier.sendMessage('Pesan kedua');

    expect(gateway.sentIds, ['uuid-1']);
    expect(gateway.sentMessages, ['Pesan pertama']);
    expect(generatedIds, 1);

    completer.complete(
      ChatExchange(
        userMessage: _message(31, ChatRole.orangTua),
        assistantMessage: _message(32, ChatRole.assistant),
        idempotent: false,
      ),
    );
    await firstSend;
  });

  test('pengukuran lama berada dalam mode read-only dan menolak pengiriman',
      () async {
    final gateway = _FakeGateway()..history = _conversation(isActive: false);
    final notifier = ChatNotifier(pengukuranId: 12, gateway: gateway);

    await notifier.load();
    await notifier.sendMessage('Tidak boleh terkirim');

    expect(notifier.state.isReadOnly, isTrue);
    expect(notifier.state.isActiveMode, isFalse);
    expect(notifier.state.canSend, isFalse);
    expect(gateway.sentIds, isEmpty);
    expect(notifier.state.conversation?.messages, isEmpty);
  });

  test('history tetap dimuat kembali setelah notifier dibuka ulang', () async {
    final gateway = _FakeGateway()
      ..history = _conversation(
        messages: [
          _message(31, ChatRole.orangTua),
          _message(32, ChatRole.assistant),
        ],
      );

    final first = ChatNotifier(pengukuranId: 12, gateway: gateway);
    await first.load();
    final reopened = ChatNotifier(pengukuranId: 12, gateway: gateway);
    await reopened.load();

    expect(first.state.conversation?.messages, hasLength(2));
    expect(reopened.state.conversation?.messages, hasLength(2));
    expect(gateway.cursors, [null, null]);
  });

  test('409 insight belum siap me-refresh conversation dan menghentikan retry',
      () async {
    final gateway = _FakeGateway()
      ..historySequence.addAll([
        _conversation(),
        _conversation(insightStatus: InsightStatus.processing),
      ])
      ..nextError = const ChatApiException(
        'Insight belum siap',
        statusCode: 409,
        code: 'CHAT_INSIGHT_NOT_READY',
      );
    final notifier = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-insight',
    );

    await notifier.load();
    await notifier.sendMessage('Bagaimana hasilnya?');

    expect(gateway.cursors, [null, null]);
    expect(
        notifier.state.conversation?.insightStatus, InsightStatus.processing);
    expect(notifier.state.pendingMessage, isNull);
    expect(notifier.state.errorCode, 'CHAT_INSIGHT_NOT_READY');
    expect(notifier.state.canSend, isFalse);
  });

  test('429, 503, timeout, dan offline mempertahankan bubble untuk retry',
      () async {
    final failures = [
      const ChatApiException('Terlalu banyak pesan', statusCode: 429),
      const ChatApiException('AI tidak tersedia', statusCode: 503),
      const ChatApiException('Waktu tunggu habis'),
      const ChatApiException('Tidak ada koneksi internet'),
    ];

    for (final failure in failures) {
      final gateway = _FakeGateway()..nextError = failure;
      final notifier = ChatNotifier(
        pengukuranId: 12,
        gateway: gateway,
        messageIdGenerator: () => 'uuid-retry',
      );
      await notifier.load();
      await notifier.sendMessage('Bagaimana hasilnya?');

      expect(notifier.state.pendingMessage?.clientMessageId, 'uuid-retry');
      expect(notifier.state.canSend, isFalse);
      expect(
        notifier.state.conversation?.messages.single.sendStatus,
        ChatSendStatus.failed,
      );
    }
  });

  test('hasil load diabaikan setelah notifier di-dispose', () async {
    final completer = Completer<ChatConversation>();
    final gateway = _FakeGateway()..historyCompleter = completer;
    final notifier = ChatNotifier(pengukuranId: 12, gateway: gateway);

    final load = notifier.load();
    notifier.dispose();
    completer.complete(_conversation());

    await expectLater(load, completes);
  });

  test('hasil kirim sukses diabaikan setelah notifier di-dispose', () async {
    final completer = Completer<ChatExchange>();
    final gateway = _FakeGateway()..sendCompleter = completer;
    final notifier = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-disposed-success',
    );
    await notifier.load();

    final send = notifier.sendMessage('Bagaimana hasilnya?');
    notifier.dispose();
    completer.complete(
      ChatExchange(
        userMessage: _message(31, ChatRole.orangTua),
        assistantMessage: _message(32, ChatRole.assistant),
        idempotent: false,
      ),
    );

    await expectLater(send, completes);
  });

  test('error kirim diabaikan setelah notifier di-dispose', () async {
    final completer = Completer<ChatExchange>();
    final gateway = _FakeGateway()..sendCompleter = completer;
    final notifier = ChatNotifier(
      pengukuranId: 12,
      gateway: gateway,
      messageIdGenerator: () => 'uuid-disposed-error',
    );
    await notifier.load();

    final send = notifier.sendMessage('Bagaimana hasilnya?');
    notifier.dispose();
    completer.completeError(
      const ChatApiException('Tidak ada koneksi internet'),
    );

    await expectLater(send, completes);
  });
}
