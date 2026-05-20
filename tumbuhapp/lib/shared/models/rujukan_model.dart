class RujukanModel {
  final int id;
  final String status;
  final String catatanKader;
  final String? catatanPuskesmas;
  final String createdAt;
  final String? validatedAt;
  final double skorAkhir;
  final String kategoriRisiko;
  final String? ditanganiOleh;

  RujukanModel({
    required this.id,
    required this.status,
    required this.catatanKader,
    this.catatanPuskesmas,
    required this.createdAt,
    this.validatedAt,
    required this.skorAkhir,
    required this.kategoriRisiko,
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
      skorAkhir: double.tryParse(json['skor_akhir'].toString()) ?? 0,
      kategoriRisiko: json['kategori_risiko'] ?? '',
      ditanganiOleh: json['ditangani_oleh'],
    );
  }
}
