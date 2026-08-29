class RujukanModel {
  final int id;
  final String status;
  final String catatanKader;
  final String? catatanPuskesmas;
  final String createdAt;
  final String? validatedAt;
  final double skorSaw;
  final String kategoriPrioritas;
  final String? ditanganiOleh;

  RujukanModel({
    required this.id,
    required this.status,
    required this.catatanKader,
    this.catatanPuskesmas,
    required this.createdAt,
    this.validatedAt,
    required this.skorSaw,
    required this.kategoriPrioritas,
    this.ditanganiOleh,
  });

  factory RujukanModel.fromJson(Map<String, dynamic> json) {
    return RujukanModel(
      id: json['id'],
      status: json['status'] ?? '',
      catatanKader: json['catatan_kader'] ?? '',
      catatanPuskesmas: json['catatan_puskesmas'],
      createdAt: json['created_at'] ?? '',
      validatedAt: json['validated_at'],
      skorSaw: double.tryParse(json['skor_saw'].toString()) ?? 0,
      kategoriPrioritas: json['kategori_prioritas'] ?? '',
      ditanganiOleh: json['ditangani_oleh'],
    );
  }
}
