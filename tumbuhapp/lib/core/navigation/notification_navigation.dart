class NotificationNavigation {
  NotificationNavigation._();

  static String path({
    required String tipe,
    String? anakId,
    int? rujukanId,
    int? jadwalId,
    int? pengukuranId,
  }) {
    switch (tipe) {
      case 'jadwal':
        return '/jadwal';
      case 'rujukan':
        return anakId != null && anakId.isNotEmpty
            ? '/anak/$anakId/rujukan'
            : '/notifikasi';
      case 'pengukuran':
        return anakId != null && anakId.isNotEmpty
            ? '/anak/$anakId/pengukuran'
            : '/notifikasi';
      default:
        return '/notifikasi';
    }
  }

  static String pathFromData(Map<String, dynamic> data) {
    return path(
      tipe: data['tipe']?.toString() ?? '',
      anakId: data['anak_id']?.toString(),
      rujukanId: _asInt(data['rujukan_id']),
      jadwalId: _asInt(data['jadwal_id']),
      pengukuranId: _asInt(data['pengukuran_id']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
