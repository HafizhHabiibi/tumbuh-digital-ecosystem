import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pemberian_service.dart';
import '../../../shared/models/pemberian_model.dart';
import '../../../shared/models/anak_model.dart';

// ── Service Provider ──────────────────────────

final pemberianServiceProvider = Provider<PemberianService>((ref) {
  return PemberianService();
});

// ── Active Filter Provider ────────────────────

final pemberianFilterProvider = StateProvider<String>((ref) => 'semua');

// ── Pemberian State ───────────────────────────

class PemberianState {
  final AnakModel? anak;
  final List<PemberianModel> riwayat;
  final List<PemberianModel> filtered;
  final String activeFilter;
  final bool isLoading;
  final String? errorMessage;

  const PemberianState({
    this.anak,
    this.riwayat = const [],
    this.filtered = const [],
    this.activeFilter = 'semua',
    this.isLoading = false,
    this.errorMessage,
  });

  PemberianState copyWith({
    AnakModel? anak,
    List<PemberianModel>? riwayat,
    List<PemberianModel>? filtered,
    String? activeFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PemberianState(
      anak: anak ?? this.anak,
      riwayat: riwayat ?? this.riwayat,
      filtered: filtered ?? this.filtered,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Pemberian Notifier ────────────────────────

class PemberianNotifier extends StateNotifier<PemberianState> {
  final PemberianService _service;

  PemberianNotifier(this._service) : super(const PemberianState());

  // ── Fetch Pemberian ─────────────────────────

  Future<void> fetchPemberian(String anakId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getPemberian(anakId);
      final list = result['riwayat'] as List<PemberianModel>;

      state = state.copyWith(
        anak: result['anak'] as AnakModel,
        riwayat: list,
        filtered: list,
        activeFilter: 'semua',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Filter Pemberian ────────────────────────

  void setFilter(String filter) {
    final filtered = filter == 'semua'
        ? state.riwayat
        : state.riwayat.where((p) => p.jenis == filter).toList();

    state = state.copyWith(
      activeFilter: filter,
      filtered: filtered,
    );
  }
}

// ── Provider ──────────────────────────────────

final pemberianProvider =
    StateNotifierProvider<PemberianNotifier, PemberianState>((ref) {
  return PemberianNotifier(ref.watch(pemberianServiceProvider));
});

// ── Checklist Imunisasi ───────────────────────
// Daftar imunisasi dasar Kemenkes

class ImunisasiItem {
  final String nama;
  final List<String> jadwal;

  const ImunisasiItem({required this.nama, required this.jadwal});
}

final daftarImunisasiDasar = [
  ImunisasiItem(
      nama: 'Hepatitis B',
      jadwal: ['0 bulan', '2 bulan', '3 bulan', '4 bulan']),
  ImunisasiItem(nama: 'BCG', jadwal: ['1 bulan']),
  ImunisasiItem(
      nama: 'Polio (OPV)',
      jadwal: ['1 bulan', '2 bulan', '3 bulan', '4 bulan']),
  ImunisasiItem(
      nama: 'DPT-HB-Hib',
      jadwal: ['2 bulan', '3 bulan', '4 bulan', '18 bulan']),
  ImunisasiItem(nama: 'PCV', jadwal: ['2 bulan', '3 bulan', '12 bulan']),
  ImunisasiItem(nama: 'Rotavirus', jadwal: ['2 bulan', '3 bulan', '4 bulan']),
  ImunisasiItem(nama: 'IPV', jadwal: ['4 bulan']),
  ImunisasiItem(nama: 'MR/MMR', jadwal: ['9 bulan', '18 bulan']),
  ImunisasiItem(nama: 'JE', jadwal: ['10 bulan']),
  ImunisasiItem(nama: 'Campak Rubela', jadwal: ['9 bulan', '18 bulan']),
];

// ── Computed: Imunisasi Sudah Diberikan ───────

final imunisasiStatusProvider =
    Provider.family<Map<String, bool>, List<PemberianModel>>((ref, riwayat) {
  final imunisasiDiberikan = riwayat
      .where((p) => p.jenis == 'imunisasi')
      .map((p) => p.namaItem.toLowerCase())
      .toSet();

  return {
    for (final item in daftarImunisasiDasar)
      item.nama: imunisasiDiberikan.any(
        (nama) => nama.contains(item.nama.toLowerCase()),
      ),
  };
});
