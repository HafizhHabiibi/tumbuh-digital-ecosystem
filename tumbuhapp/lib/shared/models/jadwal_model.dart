class JadwalModel {
  final int id;
  final String tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String lokasi;
  final String? keterangan;
  final String createdAt;
  final String dibuatOleh;

  JadwalModel({
    required this.id,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.lokasi,
    this.keterangan,
    required this.createdAt,
    required this.dibuatOleh,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'],
      tanggal: json['tanggal'] ?? '',
      waktuMulai: json['waktu_mulai'] ?? '',
      waktuSelesai: json['waktu_selesai'] ?? '',
      lokasi: json['lokasi'] ?? '',
      keterangan: json['keterangan'],
      createdAt: json['created_at'] ?? '',
      dibuatOleh: json['dibuat_oleh'] ?? '',
    );
  }
}
