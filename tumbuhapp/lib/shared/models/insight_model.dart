class InsightModel {
  final String insightTeks;
  final String createdAt;

  InsightModel({
    required this.insightTeks,
    required this.createdAt,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      insightTeks: json['insight_teks'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
