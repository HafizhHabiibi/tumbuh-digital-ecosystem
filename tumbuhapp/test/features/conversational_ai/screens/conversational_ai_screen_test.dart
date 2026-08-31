import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/features/conversational_ai/data/chat_service.dart';
import 'package:tumbuhapp/features/conversational_ai/models/chat_models.dart';
import 'package:tumbuhapp/features/conversational_ai/providers/chat_provider.dart';
import 'package:tumbuhapp/features/conversational_ai/screens/conversational_ai_screen.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';

ChatMessage _message(
  int id,
  ChatRole role, {
  String? content,
  ChatResponseType? responseType,
}) {
  return ChatMessage(
    id: id,
    clientMessageId: role == ChatRole.orangTua ? 'client-$id' : null,
    replyToMessageId: role == ChatRole.assistant ? id - 1 : null,
    role: role,
    content: content ??
        (role == ChatRole.orangTua
            ? 'Apa contoh protein?'
            : 'Telur dan tempe.'),
    responseType: responseType,
    createdAt: DateTime.utc(2026, 8, 29, 8),
  );
}

ChatConversation _conversation({
  bool isActive = true,
  int latestPengukuranId = 12,
  bool hasMore = false,
  List<ChatMessage> messages = const [],
}) {
  return ChatConversation(
    pengukuranId: 12,
    latestPengukuranId: latestPengukuranId,
    isActive: isActive,
    insightStatus: InsightStatus.completed,
    insightText: 'Pertumbuhan anak perlu dipantau secara rutin.',
    messages: messages,
    pagination: ChatPagination(
      hasMore: hasMore,
      nextBeforeId: hasMore ? 20 : null,
    ),
  );
}

class _FakeChatGateway implements ChatGateway {
  final ChatConversation conversation;
  Completer<ChatExchange>? sendCompleter;
  ChatApiException? sendError;

  _FakeChatGateway(this.conversation);

  @override
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  }) async {
    return conversation;
  }

  @override
  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  }) async {
    final error = sendError;
    sendError = null;
    if (error != null) throw error;
    return sendCompleter!.future;
  }
}

Widget _app(
  _FakeChatGateway gateway, {
  ValueChanged<int>? onOpenLatestMeasurement,
}) {
  return ProviderScope(
    overrides: [chatServiceProvider.overrideWithValue(gateway)],
    child: MaterialApp(
      home: ConversationalAiScreen(
        pengukuranId: 12,
        tanggalPengukuran: '2026-08-29',
        onOpenLatestMeasurement: onOpenLatestMeasurement,
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  testWidgets('menampilkan konteks, history, indikator respons, dan composer',
      (tester) async {
    final gateway = _FakeChatGateway(
      _conversation(
        hasMore: true,
        messages: [
          _message(21, ChatRole.orangTua),
          _message(
            22,
            ChatRole.assistant,
            content: 'Saya tidak dapat memberikan diagnosis.',
            responseType: ChatResponseType.medicalAdviceRefused,
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(gateway));
    await tester.pumpAndSettle();

    expect(find.text('AI Insight Chat'), findsOneWidget);
    expect(find.text('Pengukuran 29 Agustus 2026'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Lihat insight awal'), findsOneWidget);
    expect(find.text('Muat pesan sebelumnya'), findsOneWidget);
    expect(find.text('Apa contoh protein?'), findsOneWidget);
    final userMessage = tester.widget<Text>(find.text('Apa contoh protein?'));
    expect(userMessage.style?.color, Colors.white);
    expect(userMessage.style?.fontWeight, FontWeight.w500);
    expect(find.text('Bukan saran medis'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-composer')), findsOneWidget);
    expect(
      find.text('Jawaban bersifat edukatif dan bukan diagnosis medis.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('insight-context-card')));
    await tester.pumpAndSettle();
    expect(
      find.text('Pertumbuhan anak perlu dipantau secara rutin.'),
      findsOneWidget,
    );
  });

  testWidgets('menampilkan optimistic bubble selama pesan dikirim',
      (tester) async {
    final completer = Completer<ChatExchange>();
    final gateway = _FakeChatGateway(_conversation())
      ..sendCompleter = completer;

    await tester.pumpWidget(_app(gateway));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat-composer')),
      'Apa contoh sumber protein?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-chat-message')));
    await tester.pump();

    expect(find.text('Apa contoh sumber protein?'), findsOneWidget);
    expect(find.text('Mengirim...'), findsOneWidget);

    completer.complete(
      ChatExchange(
        userMessage: _message(
          31,
          ChatRole.orangTua,
          content: 'Apa contoh sumber protein?',
        ),
        assistantMessage: _message(
          32,
          ChatRole.assistant,
          content: 'Telur, ikan, tahu, dan tempe.',
          responseType: ChatResponseType.answered,
        ),
        idempotent: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mengirim...'), findsNothing);
    expect(find.text('Telur, ikan, tahu, dan tempe.'), findsOneWidget);
  });

  testWidgets('mode riwayat menampilkan banner tanpa composer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = _FakeChatGateway(
      _conversation(isActive: false, latestPengukuranId: 15),
    );
    int? openedMeasurementId;

    await tester.pumpWidget(
      _app(
        gateway,
        onOpenLatestMeasurement: (id) => openedMeasurementId = id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat'), findsOneWidget);
    expect(
      find.text('Ini adalah percakapan dari pengukuran sebelumnya.'),
      findsOneWidget,
    );
    expect(find.text('Buka pengukuran terbaru'), findsOneWidget);
    await tester.tap(find.text('Buka pengukuran terbaru'));
    expect(openedMeasurementId, 15);
    expect(find.byKey(const ValueKey('chat-composer')), findsNothing);
    expect(
      find.text('Jawaban bersifat edukatif dan bukan diagnosis medis.'),
      findsOneWidget,
    );
  });

  testWidgets('pesan gagal menampilkan status dan tombol retry',
      (tester) async {
    final gateway = _FakeChatGateway(_conversation())
      ..sendError = const ChatApiException(
        'Layanan AI sementara tidak tersedia',
        statusCode: 503,
      );

    await tester.pumpWidget(_app(gateway));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat-composer')),
      'Apa yang perlu dipantau?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-chat-message')));
    await tester.pumpAndSettle();

    expect(find.text('Gagal dikirim'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.text('Layanan AI sementara tidak tersedia'), findsOneWidget);
  });

  testWidgets('400 PII ditampilkan dekat composer dan input dapat diperbaiki',
      (tester) async {
    final gateway = _FakeChatGateway(_conversation())
      ..sendError = const ChatApiException(
        'Hapus data pribadi dari pertanyaan',
        statusCode: 400,
        code: 'CHAT_PII_DETECTED',
      );

    await tester.pumpWidget(_app(gateway));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat-composer')),
      'Nama anak saya adalah data pribadi',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-chat-message')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('chat-composer-error')), findsOneWidget);
    expect(
      find.text(
        'Hapus nama, NIK, nomor telepon, atau informasi pribadi dari '
        'pertanyaan Anda.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('chat-composer')))
          .enabled,
      isTrue,
    );
  });

  testWidgets('429 menonaktifkan input dan mempertahankan tombol retry',
      (tester) async {
    final gateway = _FakeChatGateway(_conversation())
      ..sendError = const ChatApiException(
        'Terlalu banyak pesan, coba kembali nanti',
        statusCode: 429,
        code: 'CHAT_RATE_LIMITED',
      );

    await tester.pumpWidget(_app(gateway));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chat-composer')),
      'Apa yang perlu dipantau?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('send-chat-message')));
    await tester.pumpAndSettle();

    expect(
        find.text('Terlalu banyak pesan, coba kembali nanti'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('chat-composer')))
          .enabled,
      isFalse,
    );
  });
}
