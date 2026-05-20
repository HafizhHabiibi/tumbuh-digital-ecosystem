class AnakModel {
  final String id;
  final String nama;
  final String jenisKelamin;
  final String tanggalLahir;
  final String noKk;
  final String createdAt;

  // Hanya ada di detail anak
  final String? orangTuaId;
  final String? namaOrangTua;
  final String? noHpOrangTua;
  final String? alamatOrangTua;

  AnakModel({
    required this.id,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.noKk,
    required this.createdAt,
    this.orangTuaId,
    this.namaOrangTua,
    this.noHpOrangTua,
    this.alamatOrangTua,
  });

  factory AnakModel.fromJson(Map<String, dynamic> json) {
    return AnakModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      noKk: json['no_kk'] ?? '',
      createdAt: json['created_at'] ?? '',
      orangTuaId: json['orang_tua_id'],
      namaOrangTua: json['nama_orang_tua'],
      noHpOrangTua: json['no_hp_orang_tua'],
      alamatOrangTua: json['alamat_orang_tua'],
    );
  }
}
