import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/auth/data/auth_service.dart';
import 'package:tumbuhapp/features/auth/providers/auth_provider.dart';
import 'package:tumbuhapp/features/conversational_ai/data/chat_service.dart';
import 'package:tumbuhapp/features/conversational_ai/models/chat_models.dart';
import 'package:tumbuhapp/features/conversational_ai/providers/chat_provider.dart';
import 'package:tumbuhapp/features/conversational_ai/widgets/chat_entry_card.dart';
import 'package:tumbuhapp/router/app_router.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';
import 'package:tumbuhapp/shared/models/user_model.dart';

class _AuthenticatedAuthNotifier extends AuthNotifier {
  _AuthenticatedAuthNotifier()
      : super(
          AuthService(dio: Dio()),
          hasStoredSession: () => Completer<bool>().future,
          getFcmToken: () async => null,
        ) {
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 'orang-tua-1',
        userId: 'user-1',
        email: 'test@example.com',
        namaLengkap: 'Orang Tua',
        noHp: '',
        alamat: '',
        nik: '',
        createdAt: '2026-08-29T00:00:00Z',
        updatedAt: '2026-08-29T00:00:00Z',
      ),
    );
  }
}

class _RouterChatGateway implements ChatGateway {
  @override
  Future<ChatConversation> getHistory(
    int pengukuranId, {
    int limit = 50,
    int? beforeId,
  }) async {
    return ChatConversation(
      pengukuranId: pengukuranId,
      isActive: true,
      insightStatus: InsightStatus.completed,
      insightText: 'Insight awal',
      messages: const [],
      pagination: const ChatPagination(
        hasMore: false,
        nextBeforeId: null,
      ),
    );
  }

  @override
  Future<ChatExchange> sendMessage({
    required int pengukuranId,
    required String clientMessageId,
    required String message,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('tombol chat aktif setelah insight completed', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatEntryCard(
            insightStatus: InsightStatus.completed,
            onPressed: () => opened = true,
          ),
        ),
      ),
    );

    final button = find.byKey(const ValueKey('open-conversational-ai'));
    expect(find.text('Tanya lebih lanjut'), findsOneWidget);
    expect(
      find.text('Percakapan tersedia setelah insight selesai.'),
      findsNothing,
    );

    await tester.tap(button);
    expect(opened, isTrue);
  });

  for (final status in <InsightStatus?>[
    null,
    InsightStatus.pending,
    InsightStatus.processing,
    InsightStatus.failed,
  ]) {
    testWidgets('tombol chat nonaktif untuk status ${status?.name ?? 'null'}',
        (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatEntryCard(
              insightStatus: status,
              onPressed: () => opened = true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('open-conversational-ai')),
      );
      expect(button.onPressed, isNull);
      expect(
        find.text('Percakapan tersedia setelah insight selesai.'),
        findsOneWidget,
      );
      expect(opened, isFalse);
    });
  }

  testWidgets('status superseded menjelaskan chat historis tidak tersedia',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatEntryCard(
            insightStatus: InsightStatus.superseded,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Percakapan tidak tersedia karena AI Insight tidak dibuat untuk '
        'pengukuran historis ini.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('open-conversational-ai')),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Percakapan tersedia setelah insight selesai.'),
        findsNothing);
  });

  test('lokasi chat mendukung navigasi dengan tanggal dan deep link ID', () {
    expect(
      AppRoutes.chatPengukuranLocation(
        12,
        tanggalPengukuran: '2026-08-29',
      ),
      '/pengukuran/12/chat?tanggal=2026-08-29',
    );
    expect(
      AppRoutes.chatPengukuranLocation(12),
      '/pengukuran/12/chat',
    );
    expect(
      AppRoutes.chatPengukuran,
      '/pengukuran/:pengukuranId/chat',
    );
  });

  testWidgets('router membuka halaman chat langsung berdasarkan ID',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => _AuthenticatedAuthNotifier()),
        chatServiceProvider.overrideWithValue(_RouterChatGateway()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    addTearDown(router.dispose);
    router.go('/pengukuran/12/chat');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tanya AI'), findsOneWidget);
    expect(find.text('Pengukuran #12'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
  });
}
