import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/features/pemberian/data/pemberian_service.dart';
import 'package:tumbuhapp/features/pemberian/providers/pemberian_provider.dart';
import 'package:tumbuhapp/features/pemberian/screens/riwayat_pemberian_screen.dart';
import 'package:tumbuhapp/shared/models/anak_model.dart';
import 'package:tumbuhapp/shared/models/pemberian_model.dart';

const _anakId = '01900000-0000-7000-8000-000000000001';

final _anak = AnakModel(
  id: _anakId,
  nama: 'Budi',
  jenisKelamin: 'L',
  tanggalLahir: '2024-08-26',
  nik: '3200000000000001',
  createdAt: '2026-08-26T03:00:00.000Z',
  namaOrangTua: 'Aminah',
  noHpOrangTua: '081234567890',
  alamatOrangTua: 'Desa Melati',
);

PemberianModel _item({
  required int id,
  required String jenis,
  required String tanggal,
  String? dosis,
  String? keterangan,
  String dicatatOleh = 'Kader Satu',
}) {
  return PemberianModel(
    id: id,
    jenis: jenis,
    dosis: dosis,
    tanggalPemberian: tanggal,
    keterangan: keterangan,
    createdAt: '${tanggal}T03:00:00.000Z',
    dicatatOleh: dicatatOleh,
  );
}

class _FakePemberianNotifier extends PemberianNotifier {
  _FakePemberianNotifier(List<PemberianModel> items)
      : super(PemberianService(dio: Dio())) {
    state = PemberianState(
      anak: _anak,
      riwayat: items,
      filtered: items,
    );
  }

  @override
  Future<void> fetchPemberian(String anakId) async {}
}

Widget _app(List<PemberianModel> items) {
  return ProviderScope(
    overrides: [
      pemberianProvider.overrideWith(
        (ref) => _FakePemberianNotifier(items),
      ),
    ],
    child: const MaterialApp(
      home: RiwayatPemberianScreen(anakId: _anakId),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  testWidgets('menampilkan informasi pemberian dengan hierarki yang jelas',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app([
        _item(
          id: 2,
          jenis: 'pmt_biskuit',
          tanggal: '2026-07-15',
          dosis: '1 paket',
        ),
        _item(
          id: 1,
          jenis: 'vitamin_a_merah',
          tanggal: '2026-08-29',
          dosis: '200.000 SI',
          keterangan: 'Diberikan setelah makan',
        ),
        _item(
          id: 3,
          jenis: 'obat_cacing',
          tanggal: '2026-08-10',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Pemberian'), findsOneWidget);
    expect(find.text('Budi'), findsNothing);
    expect(find.textContaining('Catatan layanan'), findsNothing);
    expect(find.text('Semua (3)'), findsOneWidget);
    expect(find.text('Vitamin A (1)'), findsOneWidget);
    expect(find.text('Agustus 2026'), findsOneWidget);
    expect(find.text('2 pemberian'), findsOneWidget);
    expect(find.text('Vitamin A Merah'), findsOneWidget);
    expect(find.text('29 Agustus 2026'), findsOneWidget);
    expect(find.text('Dosis'), findsWidgets);
    expect(find.text('200.000 SI'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Diberikan setelah makan'), findsOneWidget);
    expect(find.text('Dicatat oleh Kader Satu'), findsWidgets);

    await tester.drag(
      find.byKey(const ValueKey('pemberian-filter-list')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Obat Cacing (1)'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('pemberian-filter-list')),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('PMT (1)'), findsOneWidget);

    await tester.tap(find.text('PMT (1)'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pemberian-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('pemberian-1')), findsNothing);
    expect(find.byKey(const ValueKey('pemberian-3')), findsNothing);
  });

  testWidgets('empty state menjelaskan kategori yang belum memiliki riwayat',
      (tester) async {
    await tester.pumpWidget(
      _app([
        _item(
          id: 1,
          jenis: 'vitamin_a_biru',
          tanggal: '2026-08-29',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('PMT (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Riwayat PMT'), findsOneWidget);
    expect(
      find.text(
        'Catatan akan muncul setelah pemberian dilakukan oleh petugas Posyandu.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty state umum menyebut jenis layanan yang tersedia',
      (tester) async {
    await tester.pumpWidget(_app([]));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Pemberian'), findsOneWidget);
    expect(
      find.textContaining('Vitamin A, obat cacing'),
      findsOneWidget,
    );
  });
}
