import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notifikasi_service.dart';
import '../../../shared/models/notifikasi_model.dart.dart';

// ── Service Provider ──────────────────────────

final notifikasiServiceProvider = Provider<NotifikasiService>((ref) {
  return NotifikasiService();
});

// ── Belum Dibaca Provider ─────────────────────
// Dipakai di dashboard untuk badge count

final belumDibacaProvider = FutureProvider<int>((ref) async {
  return ref.watch(notifikasiServiceProvider).getBelumDibaca();
});

// ── Notifikasi State ──────────────────────────

class NotifikasiState {
  final List<NotifikasiModel> notifikasi;
  final List<NotifikasiModel> filtered;
  final int total;
  final int belumDibaca;
  final String activeFilter;
  final bool isLoading;
  final String? errorMessage;

  const NotifikasiState({
    this.notifikasi = const [],
    this.filtered = const [],
    this.total = 0,
    this.belumDibaca = 0,
    this.activeFilter = 'semua',
    this.isLoading = false,
    this.errorMessage,
  });

  NotifikasiState copyWith({
    List<NotifikasiModel>? notifikasi,
    List<NotifikasiModel>? filtered,
    int? total,
    int? belumDibaca,
    String? activeFilter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotifikasiState(
      notifikasi: notifikasi ?? this.notifikasi,
      filtered: filtered ?? this.filtered,
      total: total ?? this.total,
      belumDibaca: belumDibaca ?? this.belumDibaca,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifikasi Notifier ───────────────────────

class NotifikasiNotifier extends StateNotifier<NotifikasiState> {
  final NotifikasiService _service;
  final Ref _ref;

  NotifikasiNotifier(this._service, this._ref) : super(const NotifikasiState());

  // ── Fetch Notifikasi ────────────────────────

  Future<void> fetchNotifikasi() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getNotifikasi();
      final list = result['notifikasi'] as List<NotifikasiModel>;

      state = state.copyWith(
        notifikasi: list,
        filtered: list,
        total: result['total'] as int,
        belumDibaca: result['belumDibaca'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Filter Notifikasi ───────────────────────

  void setFilter(String filter) {
    final filtered = filter == 'semua'
        ? state.notifikasi
        : state.notifikasi.where((n) => n.tipe == filter).toList();

    state = state.copyWith(
      activeFilter: filter,
      filtered: filtered,
    );
  }

  // ── Tandai Dibaca ───────────────────────────

  Future<void> bacaNotifikasi(int id) async {
    try {
      await _service.bacaNotifikasi(id);

      // Update state lokal tanpa fetch ulang
      final updated = state.notifikasi.map((n) {
        return n.id == id
            ? NotifikasiModel(
                id: n.id,
                judul: n.judul,
                pesan: n.pesan,
                tipe: n.tipe,
                sudahDibaca: true,
                sentAt: n.sentAt,
                rujukanId: n.rujukanId,
                jadwalId: n.jadwalId,
              )
            : n;
      }).toList();

      final belumDibaca = updated.where((n) => !n.sudahDibaca).length;

      state = state.copyWith(
        notifikasi: updated,
        filtered: _applyFilter(updated, state.activeFilter),
        belumDibaca: belumDibaca,
      );

      // Refresh badge di dashboard
      _ref.refresh(belumDibacaProvider);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Tandai Semua Dibaca ─────────────────────

  Future<void> bacaSemuaNotifikasi() async {
    try {
      await _service.bacaSemuaNotifikasi();

      final updated = state.notifikasi.map((n) {
        return NotifikasiModel(
          id: n.id,
          judul: n.judul,
          pesan: n.pesan,
          tipe: n.tipe,
          sudahDibaca: true,
          sentAt: n.sentAt,
          rujukanId: n.rujukanId,
          jadwalId: n.jadwalId,
        );
      }).toList();

      state = state.copyWith(
        notifikasi: updated,
        filtered: _applyFilter(updated, state.activeFilter),
        belumDibaca: 0,
      );

      // Refresh badge di dashboard
      _ref.refresh(belumDibacaProvider);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Helper ──────────────────────────────────

  List<NotifikasiModel> _applyFilter(
    List<NotifikasiModel> list,
    String filter,
  ) {
    if (filter == 'semua') return list;
    return list.where((n) => n.tipe == filter).toList();
  }
}

// ── Provider ──────────────────────────────────

final notifikasiProvider =
    StateNotifierProvider<NotifikasiNotifier, NotifikasiState>((ref) {
  return NotifikasiNotifier(
    ref.watch(notifikasiServiceProvider),
    ref,
  );
});
