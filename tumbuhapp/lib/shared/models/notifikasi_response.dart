import 'notifikasi_model.dart';

class NotifikasiResponse {
  final int total;
  final int belumDibaca;
  final List<NotifikasiModel> notifikasi;

  NotifikasiResponse({
    required this.total,
    required this.belumDibaca,
    required this.notifikasi,
  });
}
