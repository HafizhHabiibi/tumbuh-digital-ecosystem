enum InsightStatus {
  pending,
  processing,
  completed,
  failed,
  superseded;

  static InsightStatus fromJson(Object? value) {
    switch (value) {
      case 'pending':
        return InsightStatus.pending;
      case 'processing':
        return InsightStatus.processing;
      case 'completed':
        return InsightStatus.completed;
      case 'failed':
        return InsightStatus.failed;
      case 'superseded':
        return InsightStatus.superseded;
      default:
        throw FormatException('Status insight tidak valid: $value');
    }
  }
}

class InsightModel {
  final InsightStatus status;
  final String? insightTeks;
  final String? insightGeneratedAt;

  const InsightModel({
    required this.status,
    required this.insightTeks,
    required this.insightGeneratedAt,
  });

  bool get isInProgress =>
      status == InsightStatus.pending || status == InsightStatus.processing;

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      status: InsightStatus.fromJson(json['insight_status']),
      insightTeks: json['insight_teks']?.toString(),
      insightGeneratedAt: json['insight_generated_at']?.toString(),
    );
  }
}
