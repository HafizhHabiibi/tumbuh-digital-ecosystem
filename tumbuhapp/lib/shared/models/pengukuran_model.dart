class PengukuranModel {
  final int id;
  final String tanggalUkur;
  final double beratBadan;
  final double tinggiBadan;
  final double? lingkarKepala;
  final double? lingkarLengan;
  final double zscoreBbu;
  final double zscoreTbu;
  final double zscoreBbtb;
  final String statusGizi;
  final String createdAt;
  final double skorAkhir;
  final String kategoriRisiko;

  PengukuranModel({
    required this.id,
    required this.tanggalUkur,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
    this.lingkarLengan,
    required this.zscoreBbu,
    required this.zscoreTbu,
    required this.zscoreBbtb,
    required this.statusGizi,
    required this.createdAt,
    required this.skorAkhir,
    required this.kategoriRisiko,
  });

  factory PengukuranModel.fromJson(Map<String, dynamic> json) {
    return PengukuranModel(
      id: json['id'],
      tanggalUkur: json['tanggal_ukur'] ?? '',
      beratBadan: double.tryParse(json['berat_badan'].toString()) ?? 0,
      tinggiBadan: double.tryParse(json['tinggi_badan'].toString()) ?? 0,
      lingkarKepala: json['lingkar_kepala'] != null
          ? double.tryParse(json['lingkar_kepala'].toString())
          : null,
      lingkarLengan: json['lingkar_lengan'] != null
          ? double.tryParse(json['lingkar_lengan'].toString())
          : null,
      zscoreBbu: double.tryParse(json['zscore_bbu'].toString()) ?? 0,
      zscoreTbu: double.tryParse(json['zscore_tbu'].toString()) ?? 0,
      zscoreBbtb: double.tryParse(json['zscore_bbtb'].toString()) ?? 0,
      statusGizi: json['status_gizi'] ?? '',
      createdAt: json['created_at'] ?? '',
      skorAkhir: double.tryParse(json['skor_akhir'].toString()) ?? 0,
      kategoriRisiko: json['kategori_risiko'] ?? '',
    );
  }
}
