class RujukanModel {
  static const _statusValues = {'diajukan', 'ditangani', 'selesai'};

  final int id;
  final String status;
  final String? catatanKader;
  final String? catatanPuskesmas;
  final String createdAt;
  final String? validatedAt;
  final String? completedAt;
  final String tanggalUkur;
  final double beratBadan;
  final double tinggiBadan;
  final String? ditanganiOleh;

  RujukanModel({
    required this.id,
    required this.status,
    this.catatanKader,
    this.catatanPuskesmas,
    required this.createdAt,
    this.validatedAt,
    this.completedAt,
    required this.tanggalUkur,
    required this.beratBadan,
    required this.tinggiBadan,
    this.ditanganiOleh,
  });

  factory RujukanModel.fromJson(Map<String, dynamic> json) {
    return RujukanModel(
      id: _requiredPositiveInt(json, 'id'),
      status: _requiredStatus(json),
      catatanKader: _optionalString(json, 'catatan_kader'),
      catatanPuskesmas: _optionalString(json, 'catatan_puskesmas'),
      createdAt: _requiredTimestamp(json, 'created_at'),
      validatedAt: _optionalTimestamp(json, 'validated_at'),
      completedAt: _optionalTimestamp(json, 'completed_at'),
      tanggalUkur: _requiredDate(json, 'tanggal_ukur'),
      beratBadan: _requiredPositiveDouble(json, 'berat_badan'),
      tinggiBadan: _requiredPositiveDouble(json, 'tinggi_badan'),
      ditanganiOleh: _optionalString(json, 'ditangani_oleh'),
    );
  }

  static int _requiredPositiveInt(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! int || value <= 0) {
      throw FormatException('Field $field harus berupa integer positif');
    }
    return value;
  }

  static String _requiredStatus(Map<String, dynamic> json) {
    final value = json['status'];
    if (value is! String || !_statusValues.contains(value)) {
      throw const FormatException('Field status rujukan tidak valid');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field $field harus berupa string atau null');
    }
    return value;
  }

  static double _requiredPositiveDouble(
    Map<String, dynamic> json,
    String field,
  ) {
    final value = json[field];
    if (value is! num || !value.isFinite || value <= 0) {
      throw FormatException('Field $field harus berupa angka positif');
    }
    return value.toDouble();
  }

  static String _requiredDate(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw FormatException('Field $field harus menggunakan format YYYY-MM-DD');
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null || parsed.toIso8601String().substring(0, 10) != value) {
      throw FormatException('Field $field bukan tanggal kalender yang valid');
    }
    return value;
  }

  static String _requiredTimestamp(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (!_isValidUtcTimestamp(value)) {
      throw FormatException(
        'Field $field harus berupa timestamp ISO 8601 UTC',
      );
    }
    return value as String;
  }

  static String? _optionalTimestamp(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (!_isValidUtcTimestamp(value)) {
      throw FormatException(
        'Field $field harus berupa timestamp ISO 8601 UTC atau null',
      );
    }
    return value as String;
  }

  static bool _isValidUtcTimestamp(Object? value) {
    if (value is! String) return false;
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z$',
    ).firstMatch(value);
    final parsed = DateTime.tryParse(value)?.toUtc();
    return match != null &&
        parsed != null &&
        parsed.year == int.parse(match.group(1)!) &&
        parsed.month == int.parse(match.group(2)!) &&
        parsed.day == int.parse(match.group(3)!);
  }
}
