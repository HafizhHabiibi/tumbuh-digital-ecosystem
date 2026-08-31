import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/pemberian/data/pemberian_service.dart';
import 'package:tumbuhapp/features/pemberian/providers/pemberian_provider.dart';
import 'package:tumbuhapp/shared/models/pemberian_model.dart';

PemberianModel _pemberian(int id, String jenis) {
  return PemberianModel(
    id: id,
    jenis: jenis,
    tanggalPemberian: '2026-08-29',
    createdAt: '2026-08-29T00:00:00.000Z',
    dicatatOleh: 'Kader Satu',
  );
}

class _TestPemberianNotifier extends PemberianNotifier {
  _TestPemberianNotifier() : super(PemberianService(dio: Dio()));

  void isiRiwayat(List<PemberianModel> riwayat) {
    state = PemberianState(riwayat: riwayat, filtered: riwayat);
  }
}

void main() {
  late _TestPemberianNotifier notifier;

  setUp(() {
    notifier = _TestPemberianNotifier();
    notifier.isiRiwayat([
      _pemberian(1, 'vitamin_a_merah'),
      _pemberian(2, 'vitamin_a_biru'),
      _pemberian(3, 'obat_cacing'),
      _pemberian(4, 'pmt_biskuit'),
      _pemberian(5, 'pmt_susu'),
      _pemberian(6, 'pmt_lainnya'),
    ]);
  });

  tearDown(() => notifier.dispose());

  test('filter Vitamin A memuat kedua varian vitamin', () {
    notifier.setFilter('vitamin_a');

    expect(
      notifier.state.filtered.map((item) => item.jenis),
      ['vitamin_a_merah', 'vitamin_a_biru'],
    );
  });

  test('filter PMT memuat seluruh varian PMT', () {
    notifier.setFilter('pmt');

    expect(
      notifier.state.filtered.map((item) => item.jenis),
      ['pmt_biskuit', 'pmt_susu', 'pmt_lainnya'],
    );
  });

  test('filter Obat Cacing dan Semua tetap berfungsi', () {
    notifier.setFilter('obat_cacing');
    expect(
      notifier.state.filtered.map((item) => item.jenis),
      ['obat_cacing'],
    );

    notifier.setFilter('semua');
    expect(notifier.state.filtered, hasLength(6));
  });
}
