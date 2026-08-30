import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_service.dart';
import '../models/chat_models.dart';

final chatServiceProvider = Provider<ChatGateway>((ref) => ChatService());

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, int>((ref, pengukuranId) {
  final controller = ChatController(
    pengukuranId: pengukuranId,
    gateway: ref.watch(chatServiceProvider),
  );
  Future.microtask(controller.load);
  return controller;
});

class PendingChatMessage {
  final String clientMessageId;
  final String content;

  const PendingChatMessage({
    required this.clientMessageId,
    required this.content,
  });
}

class ChatState {
  final ChatConversation? conversation;
  final PendingChatMessage? pendingMessage;
  final bool isLoading;
  final bool isLoadingOlder;
  final bool isSending;
  final String? errorMessage;
  final String? errorCode;

  const ChatState({
    this.conversation,
    this.pendingMessage,
    this.isLoading = false,
    this.isLoadingOlder = false,
    this.isSending = false,
    this.errorMessage,
    this.errorCode,
  });

  bool get canSend =>
      conversation?.canSend == true &&
      pendingMessage == null &&
      !isSending &&
      !isLoading;

  ChatState copyWith({
    ChatConversation? conversation,
    PendingChatMessage? pendingMessage,
    bool clearPendingMessage = false,
    bool? isLoading,
    bool? isLoadingOlder,
    bool? isSending,
    String? errorMessage,
    String? errorCode,
    bool clearError = false,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      pendingMessage:
          clearPendingMessage ? null : pendingMessage ?? this.pendingMessage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final int pengukuranId;
  final ChatGateway gateway;
  final ChatMessageIdGenerator messageIdGenerator;

  ChatController({
    required this.pengukuranId,
    required this.gateway,
    ChatMessageIdGenerator? messageIdGenerator,
  })  : messageIdGenerator = messageIdGenerator ?? generateChatMessageId,
        super(const ChatState());

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversation = await gateway.getHistory(pengukuranId);
      state = state.copyWith(
        conversation: conversation,
        isLoading: false,
        clearError: true,
      );
    } on ChatApiException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        errorCode: error.code,
      );
    }
  }

  Future<void> loadOlder() async {
    final current = state.conversation;
    if (current == null ||
        !current.hasMore ||
        current.nextBeforeId == null ||
        state.isLoadingOlder) {
      return;
    }
    state = state.copyWith(isLoadingOlder: true, clearError: true);
    try {
      final older = await gateway.getHistory(
        pengukuranId,
        beforeId: current.nextBeforeId,
      );
      state = state.copyWith(
        conversation: current.copyWith(
          messages: _uniqueMessages([...older.messages, ...current.messages]),
          pagination: older.pagination,
        ),
        isLoadingOlder: false,
      );
    } on ChatApiException catch (error) {
      state = state.copyWith(
        isLoadingOlder: false,
        errorMessage: error.message,
        errorCode: error.code,
      );
    }
  }

  Future<void> sendMessage(String value) async {
    final content = value.trim();
    if (content.isEmpty || !state.canSend) return;
    final pending = PendingChatMessage(
      clientMessageId: messageIdGenerator(),
      content: content,
    );
    state = state.copyWith(pendingMessage: pending, clearError: true);
    await _send(pending);
  }

  Future<void> retryPending() async {
    final pending = state.pendingMessage;
    if (pending == null || state.isSending) return;
    await _send(pending);
  }

  void clearError() => state = state.copyWith(clearError: true);

  void discardPending() {
    state = state.copyWith(clearPendingMessage: true, clearError: true);
  }

  Future<void> _send(PendingChatMessage pending) async {
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final result = await gateway.sendMessage(
        pengukuranId: pengukuranId,
        clientMessageId: pending.clientMessageId,
        message: pending.content,
      );
      final current = state.conversation;
      state = state.copyWith(
        conversation: current?.copyWith(
          messages: _uniqueMessages([
            ...current.messages,
            result.userMessage,
            result.assistantMessage,
          ]),
        ),
        isSending: false,
        clearPendingMessage: true,
        clearError: true,
      );
    } on ChatApiException catch (error) {
      state = state.copyWith(
        isSending: false,
        clearPendingMessage: !error.canRetry,
        errorMessage: error.message,
        errorCode: error.code,
      );
    }
  }

  static List<ChatMessage> _uniqueMessages(List<ChatMessage> messages) {
    final byId = <int, ChatMessage>{};
    for (final message in messages) {
      byId[message.id] = message;
    }
    final result = byId.values.toList()
      ..sort((left, right) => left.id.compareTo(right.id));
    return result;
  }
}
