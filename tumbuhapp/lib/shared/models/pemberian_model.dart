class PemberianModel {
  final int id;
  final String jenis;
  final String? dosis;
  final String tanggalPemberian;
  final String? keterangan;
  final String createdAt;
  final String dicatatOleh;

  PemberianModel({
    required this.id,
    required this.jenis,
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
      dosis: json['dosis'],
      tanggalPemberian: json['tanggal_pemberian'] ?? '',
      keterangan: json['keterangan'],
      createdAt: json['created_at'] ?? '',
      dicatatOleh: json['dicatat_oleh'] ?? '',
    );
  }

  /// Kategori umum yang digunakan oleh filter dan tampilan aplikasi.
  ///
  /// Backend tetap menyimpan jenis rinci seperti `vitamin_a_merah` dan
  /// `pmt_biskuit`, sedangkan orang tua memilih kategori Vitamin A atau PMT.
  String get kategori {
    if (jenis.startsWith('vitamin_a')) return 'vitamin_a';
    if (jenis.startsWith('pmt')) return 'pmt';
    return jenis;
  }

  bool sesuaiFilter(String filter) {
    return filter == 'semua' || kategori == filter;
  }

  String get namaItem {
    switch (jenis) {
      case 'vitamin_a_merah':
        return 'Vitamin A Merah';
      case 'vitamin_a_biru':
        return 'Vitamin A Biru';
      case 'obat_cacing':
        return 'Obat Cacing';
      case 'pmt_biskuit':
        return 'PMT Biskuit';
      case 'pmt_susu':
        return 'PMT Susu';
      case 'pmt_lainnya':
        return 'PMT Lainnya';
      default:
        return jenis
            .split('_')
            .where((word) => word.isNotEmpty)
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }
}
