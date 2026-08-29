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
  final double zscoreImtu;
  final String statusBbu;
  final String statusTbu;
  final String statusBbtb;
  final String statusImtu;
  final String createdAt;
  final double skorSaw;
  final String kategoriPrioritas;

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
    required this.zscoreImtu,
    required this.statusBbu,
    required this.statusTbu,
    required this.statusBbtb,
    required this.statusImtu,
    required this.createdAt,
    required this.skorSaw,
    required this.kategoriPrioritas,
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
      zscoreImtu: double.tryParse(json['zscore_imtu'].toString()) ?? 0,
      statusBbu: json['status_bbu'] ?? '',
      statusTbu: json['status_tbu'] ?? '',
      statusBbtb: json['status_bbtb'] ?? '',
      statusImtu: json['status_imtu'] ?? '',
      createdAt: json['created_at'] ?? '',
      skorSaw: double.tryParse(json['skor_saw'].toString()) ?? 0,
      kategoriPrioritas: json['kategori_prioritas'] ?? '',
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
