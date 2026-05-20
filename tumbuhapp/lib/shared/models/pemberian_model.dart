class PemberianModel {
  final int id;
  final String jenis;
  final String namaItem;
  final String? dosis;
  final String tanggalPemberian;
  final String? keterangan;
  final String createdAt;
  final String dicatatOleh;

  PemberianModel({
    required this.id,
    required this.jenis,
    required this.namaItem,
    this.dosis,
    required this.tanggalPemberian,
    this.keterangan,
    required this.createdAt,
    required this.dicatatOleh,
  });

  factory PemberianModel.fromJson(Map<String, dynamic> json) {
    return PemberianModel(
      id: json['id'],
      jenis: json['jenis'] ?? '',
      namaItem: json['nama_item'] ?? '',
      dosis: json['dosis'],
      tanggalPemberian: json['tanggal_pemberian'] ?? '',
      keterangan: json['keterangan'],
      createdAt: json['created_at'] ?? '',
      dicatatOleh: json['dicatat_oleh'] ?? '',
    );
  }
}
