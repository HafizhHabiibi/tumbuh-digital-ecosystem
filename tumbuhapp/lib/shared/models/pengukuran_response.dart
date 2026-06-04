import 'anak_model.dart';
import 'pengukuran_model.dart';

class PengukuranResponse {
  final AnakModel anak;
  final List<PengukuranModel> riwayat;

  PengukuranResponse({
    required this.anak,
    required this.riwayat,
  });
}
