import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';
import '../models/chat_models.dart';
import '../providers/chat_provider.dart';

class ConversationalAiScreen extends ConsumerStatefulWidget {
  final int pengukuranId;
  final String? tanggalPengukuran;
  final ValueChanged<int>? onOpenLatestMeasurement;

  const ConversationalAiScreen({
    super.key,
    required this.pengukuranId,
    this.tanggalPengukuran,
    this.onOpenLatestMeasurement,
  });

  @override
  ConsumerState<ConversationalAiScreen> createState() =>
      _ConversationalAiScreenState();
}

class _ConversationalAiScreenState
    extends ConsumerState<ConversationalAiScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatControllerProvider(widget.pengukuranId);
    final state = ref.watch(provider);

    ref.listen<ChatState>(provider, (previous, next) {
      final previousCount = previous?.conversation?.messages.length ?? 0;
      final nextCount = next.conversation?.messages.length ?? 0;
      if (nextCount > previousCount && !next.isLoadingOlder) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState state) {
    final formattedDate = FormatUtils.formatTanggal(widget.tanggalPengukuran);
    final subtitle = formattedDate == '-'
        ? 'Pengukuran #${widget.pengukuranId}'
        : 'Pengukuran $formattedDate';
    final isHistory = state.isReadOnly;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Insight Chat', style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
      actions: [
        if (state.conversation != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _StatusBadge(isHistory: isHistory),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ChatState state) {
    final conversation = state.conversation;
    if (conversation == null && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (conversation == null) {
      return _InitialError(
        message: state.errorMessage ?? 'Percakapan tidak tersedia',
        onRetry: () => ref
            .read(chatControllerProvider(widget.pengukuranId).notifier)
            .load(),
      );
    }

    return Column(
      children: [
        if (state.isReadOnly)
          _ReadOnlyBanner(
            onOpenLatest: () =>
                _openLatestMeasurement(conversation.latestPengukuranId),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(chatControllerProvider(widget.pengukuranId).notifier)
                .load(),
            child: ListView(
              key: const ValueKey('chat-message-list'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _InsightContextCard(
                  dateLabel: _measurementLabel,
                  insightText: conversation.insightText,
                ),
                if (state.errorMessage != null && !state.hasComposerError) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(
                    message: _friendlyError(state),
                    onDismiss: () => ref
                        .read(chatControllerProvider(widget.pengukuranId)
                            .notifier)
                        .clearError(),
                  ),
                ],
                const SizedBox(height: 16),
                if (conversation.hasMore) ...[
                  Center(
                    child: OutlinedButton.icon(
                      key: const ValueKey('load-older-messages'),
                      onPressed: state.isLoadingOlder
                          ? null
                          : () => ref
                              .read(chatControllerProvider(widget.pengukuranId)
                                  .notifier)
                              .loadOlder(),
                      icon: state.isLoadingOlder
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.history, size: 18),
                      label: const Text('Muat pesan sebelumnya'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (conversation.messages.isEmpty)
                  const _EmptyConversation()
                else
                  ...conversation.messages.map(
                    (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MessageBubble(
                        message: message,
                        canRetry: state.pendingMessage?.localMessageId ==
                                message.id &&
                            state.pendingMessage?.canRetry == true,
                        onRetry: () => ref
                            .read(chatControllerProvider(widget.pengukuranId)
                                .notifier)
                            .retryPending(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!state.isReadOnly)
          _buildComposer(state)
        else
          const _EducationalDisclosure(),
      ],
    );
  }

  Widget _buildComposer(ChatState state) {
    final draftLength = state.draft.length;
    final canSubmit =
        state.canSend && state.draft.trim().length >= 2 && draftLength <= 1000;

    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.hasComposerError && state.errorMessage != null) ...[
                _ComposerError(message: _friendlyError(state)),
                const SizedBox(height: 8),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-composer'),
                      controller: _messageController,
                      focusNode: _focusNode,
                      enabled: state.canSend,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 1000,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1000),
                      ],
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) => ref
                          .read(chatControllerProvider(widget.pengukuranId)
                              .notifier)
                          .updateDraft(value),
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        if (currentLength < 900) return null;
                        return Text(
                          '$currentLength/$maxLength',
                          style: AppTextStyles.caption.copyWith(
                            color: currentLength >= 1000
                                ? AppColors.statusBurukText
                                : AppColors.textSecondary,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: state.isActiveMode
                            ? 'Tanyakan tentang hasil pengukuran'
                            : 'Percakapan tersedia setelah insight selesai',
                        hintStyle: AppTextStyles.caption.copyWith(fontSize: 13),
                        filled: true,
                        fillColor: state.isActiveMode
                            ? AppColors.background
                            : AppColors.divider,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    key: const ValueKey('send-chat-message'),
                    tooltip: 'Kirim pesan',
                    onPressed: canSubmit ? _sendMessage : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      minimumSize: const Size.square(48),
                    ),
                    icon: state.isSending
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const _EducationalDisclosure(compact: true),
            ],
          ),
        ),
      ),
    );
  }

  String get _measurementLabel {
    final formattedDate = FormatUtils.formatTanggal(widget.tanggalPengukuran);
    return formattedDate == '-' ? '#${widget.pengukuranId}' : formattedDate;
  }

  String _friendlyError(ChatState state) {
    if (state.errorCode == 'CHAT_PII_DETECTED') {
      return 'Hapus nama, NIK, nomor telepon, atau informasi pribadi dari '
          'pertanyaan Anda.';
    }
    return state.errorMessage ?? 'Terjadi kesalahan pada percakapan';
  }

  Future<void> _sendMessage() async {
    final notifier =
        ref.read(chatControllerProvider(widget.pengukuranId).notifier);
    final sending = notifier.sendDraft();
    _messageController.clear();
    await sending;
    if (!mounted) return;
    final state = ref.read(chatControllerProvider(widget.pengukuranId));
    if (state.pendingMessage == null && state.errorMessage == null) {
      _focusNode.unfocus();
    }
  }

  void _openLatestMeasurement(int latestPengukuranId) {
    final callback = widget.onOpenLatestMeasurement;
    if (callback != null) {
      callback(latestPengukuranId);
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isHistory;

  const _StatusBadge({required this.isHistory});

  @override
  Widget build(BuildContext context) {
    final color =
        isHistory ? AppColors.textSecondary : AppColors.statusNormalText;
    final background = isHistory ? AppColors.divider : AppColors.statusNormalBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isHistory ? 'Riwayat' : 'Aktif',
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _InsightContextCard extends StatelessWidget {
  final String dateLabel;
  final String? insightText;

  const _InsightContextCard({
    required this.dateLabel,
    required this.insightText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const ValueKey('insight-context-card'),
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(Icons.auto_awesome, color: AppColors.primary),
          title: Text(
            'Percakapan ini membahas hasil pengukuran $dateLabel.',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle:
              const Text('Lihat insight awal', style: AppTextStyles.caption),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                insightText?.trim().isNotEmpty == true
                    ? insightText!
                    : 'Insight awal tidak tersedia.',
                style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool canRetry;
  final VoidCallback onRetry;

  const _MessageBubble({
    required this.message,
    required this.canRetry,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.orangTua;
    final bubbleColor = isUser ? AppColors.primary : AppColors.surface;
    final textColor = isUser ? Colors.white : AppColors.textPrimary;

    return Align(
      key: ValueKey('chat-message-${message.id}'),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser ? null : Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.responseType != null &&
                    message.responseType != ChatResponseType.answered) ...[
                  _ResponseTypeLabel(type: message.responseType!),
                  const SizedBox(height: 8),
                ],
                Text(
                  message.content,
                  style: AppTextStyles.body.copyWith(
                    color: textColor,
                    height: 1.45,
                    fontWeight: isUser ? FontWeight.w500 : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timeLabel(message),
                      style: AppTextStyles.caption.copyWith(
                        color: isUser ? Colors.white : AppColors.textMuted,
                        fontWeight: isUser ? FontWeight.w500 : null,
                      ),
                    ),
                    if (message.sendStatus == ChatSendStatus.sending) ...[
                      const SizedBox(width: 6),
                      const SizedBox.square(
                        dimension: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mengirim...',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (message.sendStatus == ChatSendStatus.failed) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.error_outline,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        'Gagal dikirim',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (message.sendStatus == ChatSendStatus.failed && canRetry)
                  TextButton.icon(
                    key: ValueKey('retry-message-${message.id}'),
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.only(top: 4),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.refresh, size: 17),
                    label: const Text('Coba lagi'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _timeLabel(ChatMessage message) {
    if (message.createdAt == null) return '';
    return FormatUtils.formatJam(message.createdAt!.toIso8601String());
  }
}

class _ResponseTypeLabel extends StatelessWidget {
  final ChatResponseType type;

  const _ResponseTypeLabel({required this.type});

  @override
  Widget build(BuildContext context) {
    final isMedical = type == ChatResponseType.medicalAdviceRefused;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMedical ? AppColors.statusKurangBg : AppColors.divider,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMedical ? Icons.health_and_safety_outlined : Icons.info_outline,
            size: 14,
            color: isMedical
                ? AppColors.statusKurangText
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            isMedical ? 'Bukan saran medis' : 'Di luar lingkup',
            style: AppTextStyles.label.copyWith(
              color: isMedical
                  ? AppColors.statusKurangText
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  final VoidCallback onOpenLatest;

  const _ReadOnlyBanner({required this.onOpenLatest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: AppColors.statusKurangBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history, color: AppColors.statusKurangText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ini adalah percakapan dari pengukuran sebelumnya.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 4),
                TextButton(
                  key: const ValueKey('open-latest-measurement'),
                  onPressed: onOpenLatest,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Buka pengukuran terbaru'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusBurukBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.statusBurukText),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.body)),
          IconButton(
            tooltip: 'Tutup',
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

class _InitialError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InitialError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 40, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text('Belum ada percakapan', style: AppTextStyles.heading3),
          SizedBox(height: 4),
          Text(
            'Ajukan pertanyaan tentang hasil pengukuran ini.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EducationalDisclosure extends StatelessWidget {
  final bool compact;

  const _EducationalDisclosure({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 16,
        vertical: compact ? 0 : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              'Jawaban bersifat edukatif dan bukan diagnosis medis.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerError extends StatelessWidget {
  final String message;

  const _ComposerError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('chat-composer-error'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline,
          size: 16,
          color: AppColors.statusBurukText,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.statusBurukText,
            ),
          ),
        ),
      ],
    );
  }
}
