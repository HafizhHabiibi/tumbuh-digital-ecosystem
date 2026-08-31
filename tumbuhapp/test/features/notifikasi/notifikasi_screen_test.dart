import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/features/notifikasi/data/notifikasi_service.dart';
import 'package:tumbuhapp/features/notifikasi/providers/notifikasi_provider.dart';
import 'package:tumbuhapp/features/notifikasi/screens/notifikasi_screen.dart';
import 'package:tumbuhapp/shared/models/notifikasi_model.dart';
import 'package:tumbuhapp/shared/models/notifikasi_response.dart';

NotifikasiModel _notifikasi({
  required int id,
  required String tipe,
  required String judul,
  bool sudahDibaca = false,
  String? anakId,
  int? pengukuranId,
}) {
  return NotifikasiModel(
    id: id,
    judul: judul,
    pesan: 'Pesan $judul',
    tipe: tipe,
    sudahDibaca: sudahDibaca,
    sentAt: '2026-08-30T08:00:00.000Z',
    anakId: anakId,
    pengukuranId: pengukuranId,
  );
}

class _FakeNotifikasiService extends NotifikasiService {
  _FakeNotifikasiService(this.items) : super(dio: Dio());

  final List<NotifikasiModel> items;
  final List<int> dibaca = [];
  int bacaSemuaCalls = 0;

  @override
  Future<NotifikasiResponse> getNotifikasi() async {
    return NotifikasiResponse(
      total: items.length,
      belumDibaca: items.where((item) => !item.sudahDibaca).length,
      notifikasi: items,
    );
  }

  @override
  Future<int> getBelumDibaca() async {
    return items.where((item) => !item.sudahDibaca).length;
  }

  @override
  Future<void> bacaNotifikasi(int id) async {
    dibaca.add(id);
  }

  @override
  Future<void> bacaSemuaNotifikasi() async {
    bacaSemuaCalls += 1;
  }
}

List<NotifikasiModel> _items() {
  return [
    _notifikasi(id: 1, tipe: 'jadwal', judul: 'Jadwal Baru'),
    _notifikasi(id: 2, tipe: 'rujukan', judul: 'Rujukan Baru'),
    _notifikasi(
      id: 3,
      tipe: 'pengukuran',
      judul: 'Hasil Pengukuran',
      anakId: '01900000-0000-7000-8000-000000000001',
      pengukuranId: 501,
    ),
  ];
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  test('filter Pengukuran menampilkan tipe yang didukung backend', () async {
    final service = _FakeNotifikasiService(_items());
    final container = ProviderContainer(
      overrides: [notifikasiServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await container.read(notifikasiProvider.notifier).fetchNotifikasi();
    container.read(notifikasiProvider.notifier).setFilter('pengukuran');

    final state = container.read(notifikasiProvider);
    expect(state.activeFilter, 'pengukuran');
    expect(state.filtered.map((item) => item.id), [3]);
  });

  test('tandai dibaca mempertahankan referensi navigasi pengukuran', () async {
    final service = _FakeNotifikasiService(_items());
    final container = ProviderContainer(
      overrides: [notifikasiServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(notifikasiProvider.notifier);
    await notifier.fetchNotifikasi();
    await notifier.bacaNotifikasi(3);

    final pengukuran = container
        .read(notifikasiProvider)
        .notifikasi
        .singleWhere((item) => item.id == 3);
    expect(pengukuran.sudahDibaca, isTrue);
    expect(pengukuran.anakId, '01900000-0000-7000-8000-000000000001');
    expect(pengukuran.pengukuranId, 501);
    expect(service.dibaca, [3]);
  });

  test('baca semua mempertahankan referensi setiap notifikasi', () async {
    final service = _FakeNotifikasiService(_items());
    final container = ProviderContainer(
      overrides: [notifikasiServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(notifikasiProvider.notifier);
    await notifier.fetchNotifikasi();
    await notifier.bacaSemuaNotifikasi();

    final state = container.read(notifikasiProvider);
    final pengukuran = state.notifikasi.singleWhere((item) => item.id == 3);
    expect(state.notifikasi.every((item) => item.sudahDibaca), isTrue);
    expect(pengukuran.anakId, '01900000-0000-7000-8000-000000000001');
    expect(pengukuran.pengukuranId, 501);
    expect(service.bacaSemuaCalls, 1);
  });

  testWidgets('tab Pengukuran menggantikan Pengingat dan memfilter daftar',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notifikasiServiceProvider.overrideWithValue(
            _FakeNotifikasiService(_items()),
          ),
        ],
        child: const MaterialApp(home: NotifikasiScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengukuran'), findsOneWidget);
    expect(find.text('Pengingat'), findsNothing);

    await tester.tap(find.text('Pengukuran'));
    await tester.pumpAndSettle();

    expect(find.text('Hasil Pengukuran'), findsOneWidget);
    expect(find.text('Jadwal Baru'), findsNothing);
    expect(find.text('Rujukan Baru'), findsNothing);
  });
}
