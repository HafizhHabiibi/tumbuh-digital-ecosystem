class NotifikasiModel {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final bool sudahDibaca;
  final String sentAt;
  final int? rujukanId;
  final int? jadwalId;

  NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    required this.sentAt,
    this.rujukanId,
    this.jadwalId,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? '',
      sudahDibaca: json['sudah_dibaca'] == 1 || json['sudah_dibaca'] == true,
      sentAt: json['sent_at'] ?? '',
      rujukanId: json['rujukan_id'],
      jadwalId: json['jadwal_id'],
    );
  }
}
