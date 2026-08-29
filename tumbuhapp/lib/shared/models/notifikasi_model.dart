class NotifikasiModel {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final bool sudahDibaca;
  final String sentAt;
  final int? rujukanId;
  final int? jadwalId;
  final int? pengukuranId;
  final String? anakId;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    required this.sentAt,
    this.rujukanId,
    this.jadwalId,
    this.pengukuranId,
    this.anakId,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? '',
      sudahDibaca: json['sudah_dibaca'] == 1 || json['sudah_dibaca'] == true,
      sentAt: json['sent_at'] ?? '',
      rujukanId: _asInt(json['rujukan_id']),
      jadwalId: _asInt(json['jadwal_id']),
      pengukuranId: _asInt(json['pengukuran_id']),
      anakId: json['anak_id']?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
