import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_service.dart';
import '../models/chat_models.dart';

final chatServiceProvider = Provider<ChatGateway>((ref) => ChatService());

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, int>((ref, pengukuranId) {
  final controller = ChatNotifier(
    pengukuranId: pengukuranId,
    gateway: ref.watch(chatServiceProvider),
  );
  Future.microtask(controller.load);
  return controller;
});

class PendingChatMessage {
  final int localMessageId;
  final String clientMessageId;
  final String content;
  final bool canRetry;

  const PendingChatMessage({
    required this.localMessageId,
    required this.clientMessageId,
    required this.content,
    this.canRetry = true,
  });

  PendingChatMessage copyWith({bool? canRetry}) {
    return PendingChatMessage(
      localMessageId: localMessageId,
      clientMessageId: clientMessageId,
      content: content,
      canRetry: canRetry ?? this.canRetry,
    );
  }
}

class ChatState {
  final ChatConversation? conversation;
  final PendingChatMessage? pendingMessage;
  final String draft;
  final bool isLoading;
  final bool isLoadingOlder;
  final bool isSending;
  final String? errorMessage;
  final String? errorCode;
  final int? errorStatusCode;

  const ChatState({
    this.conversation,
    this.pendingMessage,
    this.draft = '',
    this.isLoading = false,
    this.isLoadingOlder = false,
    this.isSending = false,
    this.errorMessage,
    this.errorCode,
    this.errorStatusCode,
  });

  bool get canSend =>
      conversation?.canSend == true &&
      pendingMessage == null &&
      !isSending &&
      !isLoading;
  bool get isReadOnly => conversation != null && !conversation!.isActive;
  bool get isActiveMode => conversation?.canSend == true;
  bool get hasComposerError => errorStatusCode == 400;

  ChatState copyWith({
    ChatConversation? conversation,
    PendingChatMessage? pendingMessage,
    bool clearPendingMessage = false,
    String? draft,
    bool? isLoading,
    bool? isLoadingOlder,
    bool? isSending,
    String? errorMessage,
    String? errorCode,
    int? errorStatusCode,
    bool clearError = false,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      pendingMessage:
          clearPendingMessage ? null : pendingMessage ?? this.pendingMessage,
      draft: draft ?? this.draft,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
      errorStatusCode:
          clearError ? null : errorStatusCode ?? this.errorStatusCode,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final int pengukuranId;
  final ChatGateway gateway;
  final ChatMessageIdGenerator messageIdGenerator;

  int _nextOptimisticId = -1;
  bool _isDisposed = false;

  ChatNotifier({
    required this.pengukuranId,
    required this.gateway,
    ChatMessageIdGenerator? messageIdGenerator,
  })  : messageIdGenerator = messageIdGenerator ?? generateChatMessageId,
        super(const ChatState());

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> load() async {
    if (_isDisposed) return;
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversation = await gateway.getHistory(pengukuranId);
      if (_isDisposed) return;
      state = state.copyWith(
        conversation: conversation,
        isLoading: false,
        clearError: true,
      );
    } on ChatApiException catch (error) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        errorCode: error.code,
        errorStatusCode: error.statusCode,
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
      if (_isDisposed) return;
      final latest = state.conversation;
      if (latest == null) {
        state = state.copyWith(isLoadingOlder: false);
        return;
      }
      state = state.copyWith(
        conversation: latest.copyWith(
          messages: _uniqueMessages([...older.messages, ...latest.messages]),
          pagination: older.pagination,
        ),
        isLoadingOlder: false,
      );
    } on ChatApiException catch (error) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoadingOlder: false,
        errorMessage: error.message,
        errorCode: error.code,
        errorStatusCode: error.statusCode,
      );
    }
  }

  void updateDraft(String value) {
    state = state.copyWith(draft: value);
  }

  Future<void> sendDraft() => sendMessage(state.draft);

  Future<void> sendMessage(String value) async {
    final content = value.trim();
    if (content.isEmpty || !state.canSend) return;
    final current = state.conversation!;
    final pending = PendingChatMessage(
      localMessageId: _nextOptimisticId--,
      clientMessageId: messageIdGenerator(),
      content: content,
    );
    final optimisticMessage = ChatMessage(
      id: pending.localMessageId,
      clientMessageId: pending.clientMessageId,
      replyToMessageId: null,
      role: ChatRole.orangTua,
      content: pending.content,
      responseType: null,
      createdAt: DateTime.now().toUtc(),
      sendStatus: ChatSendStatus.sending,
    );
    state = state.copyWith(
      conversation: current.copyWith(
        messages: [...current.messages, optimisticMessage],
      ),
      pendingMessage: pending,
      draft: '',
      isSending: true,
      clearError: true,
    );
    await _send(pending);
  }

  Future<void> retryPending() async {
    final pending = state.pendingMessage;
    if (pending == null || !pending.canRetry || state.isSending) return;
    state = state.copyWith(
      conversation: _replaceLocalMessageStatus(
        state.conversation,
        pending.localMessageId,
        ChatSendStatus.sending,
      ),
      isSending: true,
      clearError: true,
    );
    await _send(pending);
  }

  void clearError() => state = state.copyWith(clearError: true);

  void discardPending() {
    final pending = state.pendingMessage;
    final conversation = state.conversation;
    state = state.copyWith(
      conversation: pending == null || conversation == null
          ? conversation
          : conversation.copyWith(
              messages: conversation.messages
                  .where((message) => message.id != pending.localMessageId)
                  .toList(growable: false),
            ),
      clearPendingMessage: true,
      clearError: true,
    );
  }

  Future<void> _send(PendingChatMessage pending) async {
    try {
      final result = await gateway.sendMessage(
        pengukuranId: pengukuranId,
        clientMessageId: pending.clientMessageId,
        message: pending.content,
      );
      if (_isDisposed) return;
      final current = state.conversation;
      state = state.copyWith(
        conversation: current?.copyWith(
          messages: _uniqueMessages([
            ...current.messages.where(
              (message) => message.id != pending.localMessageId,
            ),
            result.userMessage,
            result.assistantMessage,
          ]),
        ),
        isSending: false,
        clearPendingMessage: true,
        clearError: true,
      );
    } on ChatApiException catch (error) {
      if (_isDisposed) return;
      final canRetry = error.canRetry;
      state = state.copyWith(
        conversation: _replaceLocalMessageStatus(
          state.conversation,
          pending.localMessageId,
          ChatSendStatus.failed,
        ),
        pendingMessage: canRetry ? pending.copyWith(canRetry: true) : null,
        isSending: false,
        clearPendingMessage: !canRetry,
        errorMessage: error.message,
        errorCode: error.code,
        errorStatusCode: error.statusCode,
      );
      if (error.code == 'CHAT_INSIGHT_NOT_READY') {
        await _refreshConversationAfterInsightNotReady(error);
      }
    }
  }

  Future<void> _refreshConversationAfterInsightNotReady(
    ChatApiException originalError,
  ) async {
    try {
      final conversation = await gateway.getHistory(pengukuranId);
      if (_isDisposed) return;
      state = state.copyWith(
        conversation: conversation,
        errorMessage: originalError.message,
        errorCode: originalError.code,
        errorStatusCode: originalError.statusCode,
      );
    } on ChatApiException {
      // Pertahankan error POST asli agar pengguna mendapat penyebab yang tepat.
    }
  }

  static ChatConversation? _replaceLocalMessageStatus(
    ChatConversation? conversation,
    int localMessageId,
    ChatSendStatus status,
  ) {
    return conversation?.copyWith(
      messages: conversation.messages
          .map(
            (message) => message.id == localMessageId
                ? message.copyWith(sendStatus: status)
                : message,
          )
          .toList(growable: false),
    );
  }

  static List<ChatMessage> _uniqueMessages(List<ChatMessage> messages) {
    final byId = <int, ChatMessage>{};
    for (final message in messages) {
      byId[message.id] = message;
    }
    return byId.values.toList(growable: false);
  }
}
