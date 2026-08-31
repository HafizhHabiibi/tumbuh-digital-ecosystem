class PengukuranModel {
  static const _statusBbuValues = {
    'berat_badan_sangat_kurang',
    'berat_badan_kurang',
    'berat_badan_normal',
    'risiko_berat_badan_lebih',
  };
  static const _statusTbuValues = {
    'sangat_pendek',
    'pendek',
    'normal',
    'tinggi',
  };
  static const _statusGiziValues = {
    'gizi_buruk',
    'gizi_kurang',
    'gizi_baik',
    'risiko_gizi_lebih',
    'gizi_lebih',
    'obesitas',
  };
  static const _statusPemantauanValues = {
    'rutin',
    'perlu_perhatian',
    'konsultasi',
  };

  final int id;
  final String tanggalUkur;
  final double beratBadan;
  final double tinggiBadan;
  final double? lingkarKepala;
  final double? lingkarLengan;
  final int usiaBulan;
  final String statusBbu;
  final String statusTbu;
  final String statusBbtb;
  final String statusImtu;
  final String statusPemantauan;
  final String createdAt;

  PengukuranModel({
    required this.id,
    required this.tanggalUkur,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
    this.lingkarLengan,
    required this.usiaBulan,
    required this.statusBbu,
    required this.statusTbu,
    required this.statusBbtb,
    required this.statusImtu,
    required this.statusPemantauan,
    required this.createdAt,
  });

  factory PengukuranModel.fromJson(Map<String, dynamic> json) {
    return PengukuranModel(
      id: _requiredPositiveInt(json, 'id'),
      tanggalUkur: _requiredDate(json, 'tanggal_ukur'),
      beratBadan: _requiredPositiveDouble(json, 'berat_badan'),
      tinggiBadan: _requiredPositiveDouble(json, 'tinggi_badan'),
      lingkarKepala: _optionalPositiveDouble(json, 'lingkar_kepala'),
      lingkarLengan: _optionalPositiveDouble(json, 'lingkar_lengan'),
      usiaBulan: _requiredNonNegativeInt(json, 'usia_bulan'),
      statusBbu: _requiredEnum(json, 'status_bbu', _statusBbuValues),
      statusTbu: _requiredEnum(json, 'status_tbu', _statusTbuValues),
      statusBbtb: _requiredEnum(json, 'status_bbtb', _statusGiziValues),
      statusImtu: _requiredEnum(json, 'status_imtu', _statusGiziValues),
      statusPemantauan: _requiredEnum(
        json,
        'status_pemantauan',
        _statusPemantauanValues,
      ),
      createdAt: _requiredTimestamp(json, 'created_at'),
    );
  }

  String statusForIndicator(String indicator) {
    switch (indicator) {
      case 'bbu':
        return statusBbu;
      case 'tbu':
        return statusTbu;
      case 'bbtb':
        return statusBbtb;
      case 'imtu':
        return statusImtu;
      default:
        return '';
    }
  }
}

int _requiredPositiveInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int || value <= 0) {
    throw FormatException('Field $field harus berupa integer positif');
  }
  return value;
}

int _requiredNonNegativeInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int || value < 0) {
    throw FormatException('Field $field harus berupa integer minimal 0');
  }
  return value;
}

double _requiredPositiveDouble(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! num || !value.isFinite || value <= 0) {
    throw FormatException('Field $field harus berupa angka positif');
  }
  return value.toDouble();
}

double? _optionalPositiveDouble(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is! num || !value.isFinite || value <= 0) {
    throw FormatException('Field $field harus berupa angka positif atau null');
  }
  return value.toDouble();
}

String _requiredEnum(
  Map<String, dynamic> json,
  String field,
  Set<String> allowed,
) {
  final value = json[field];
  if (value is! String || !allowed.contains(value)) {
    throw FormatException('Field $field memiliki nilai yang tidak valid');
  }
  return value;
}

String _requiredDate(Map<String, dynamic> json, String field) {
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

String _requiredTimestamp(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw FormatException('Field $field harus berupa timestamp ISO 8601 UTC');
  }

  final match = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z$',
  ).firstMatch(value);
  final parsed = DateTime.tryParse(value)?.toUtc();
  if (match == null ||
      parsed == null ||
      parsed.year != int.parse(match.group(1)!) ||
      parsed.month != int.parse(match.group(2)!) ||
      parsed.day != int.parse(match.group(3)!)) {
    throw FormatException('Field $field harus berupa timestamp ISO 8601 UTC');
  }
  return value;
}
