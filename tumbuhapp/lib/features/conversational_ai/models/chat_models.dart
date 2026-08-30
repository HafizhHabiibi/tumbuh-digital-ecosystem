import '../../../shared/models/insight_model.dart';

enum ChatRole {
  orangTua,
  assistant;

  static ChatRole fromJson(String value) {
    switch (value) {
      case 'orang_tua':
        return ChatRole.orangTua;
      case 'assistant':
        return ChatRole.assistant;
      default:
        throw FormatException('Role chat tidak dikenal: $value');
    }
  }
}

enum ChatResponseType {
  answered,
  outOfScope,
  medicalAdviceRefused;

  static ChatResponseType? fromJson(Object? value) {
    switch (value) {
      case null:
        return null;
      case 'answered':
        return ChatResponseType.answered;
      case 'out_of_scope':
        return ChatResponseType.outOfScope;
      case 'medical_advice_refused':
        return ChatResponseType.medicalAdviceRefused;
      default:
        throw FormatException('Tipe respons chat tidak dikenal: $value');
    }
  }
}

enum ChatSendStatus {
  pending,
  sending,
  sent,
  failed,
}

class ChatMessage {
  final int id;
  final String? clientMessageId;
  final int? replyToMessageId;
  final ChatRole role;
  final String content;
  final ChatResponseType? responseType;
  final DateTime? createdAt;
  final ChatSendStatus sendStatus;

  const ChatMessage({
    required this.id,
    required this.clientMessageId,
    required this.replyToMessageId,
    required this.role,
    required this.content,
    required this.responseType,
    required this.createdAt,
    this.sendStatus = ChatSendStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _requiredInt(json['id'], 'id'),
      clientMessageId: json['client_message_id']?.toString(),
      replyToMessageId: _optionalInt(json['reply_to_message_id']),
      role: ChatRole.fromJson(json['role']?.toString() ?? ''),
      content: json['content']?.toString() ?? '',
      responseType: ChatResponseType.fromJson(json['response_type']),
      createdAt: _optionalDateTime(json['created_at']),
      sendStatus: ChatSendStatus.sent,
    );
  }

  ChatMessage copyWith({ChatSendStatus? sendStatus}) {
    return ChatMessage(
      id: id,
      clientMessageId: clientMessageId,
      replyToMessageId: replyToMessageId,
      role: role,
      content: content,
      responseType: responseType,
      createdAt: createdAt,
      sendStatus: sendStatus ?? this.sendStatus,
    );
  }
}

class ChatPagination {
  final bool hasMore;
  final int? nextBeforeId;

  const ChatPagination({
    required this.hasMore,
    required this.nextBeforeId,
  });

  factory ChatPagination.fromJson(Map<String, dynamic> json) {
    return ChatPagination(
      hasMore: json['has_more'] == true,
      nextBeforeId: _optionalInt(json['next_before_id']),
    );
  }
}

class ChatConversation {
  final int pengukuranId;
  final int latestPengukuranId;
  final bool isActive;
  final InsightStatus insightStatus;
  final String? insightText;
  final List<ChatMessage> messages;
  final ChatPagination pagination;

  const ChatConversation({
    required this.pengukuranId,
    required this.latestPengukuranId,
    required this.isActive,
    required this.insightStatus,
    required this.insightText,
    required this.messages,
    required this.pagination,
  });

  bool get canSend => isActive && insightStatus == InsightStatus.completed;
  bool get hasMore => pagination.hasMore;
  int? get nextBeforeId => pagination.nextBeforeId;

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final pagination = _map(json['pagination'], 'pagination');
    return ChatConversation(
      pengukuranId: _requiredInt(json['pengukuran_id'], 'pengukuran_id'),
      latestPengukuranId: _requiredInt(
        json['latest_pengukuran_id'],
        'latest_pengukuran_id',
      ),
      isActive: json['is_active'] == true,
      insightStatus: InsightStatus.fromJson(json['insight_status']),
      insightText: json['insight_teks']?.toString(),
      messages: rawMessages is List
          ? rawMessages
              .map((item) => ChatMessage.fromJson(_map(item, 'message')))
              .toList(growable: false)
          : const [],
      pagination: ChatPagination.fromJson(pagination),
    );
  }

  ChatConversation copyWith({
    List<ChatMessage>? messages,
    ChatPagination? pagination,
  }) {
    return ChatConversation(
      pengukuranId: pengukuranId,
      latestPengukuranId: latestPengukuranId,
      isActive: isActive,
      insightStatus: insightStatus,
      insightText: insightText,
      messages: messages ?? this.messages,
      pagination: pagination ?? this.pagination,
    );
  }
}

class ChatExchange {
  final ChatMessage userMessage;
  final ChatMessage assistantMessage;
  final bool idempotent;

  const ChatExchange({
    required this.userMessage,
    required this.assistantMessage,
    required this.idempotent,
  });

  factory ChatExchange.fromJson(Map<String, dynamic> json) {
    return ChatExchange(
      userMessage: ChatMessage.fromJson(
        _map(json['user_message'], 'user_message'),
      ),
      assistantMessage: ChatMessage.fromJson(
        _map(json['assistant_message'], 'assistant_message'),
      ),
      idempotent: json['idempotent'] == true,
    );
  }
}

Map<String, dynamic> _map(Object? value, String field) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Field $field tidak valid');
}

int _requiredInt(Object? value, String field) {
  final parsed = _optionalInt(value);
  if (parsed != null) return parsed;
  throw FormatException('Field $field tidak valid');
}

int? _optionalInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _optionalDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
