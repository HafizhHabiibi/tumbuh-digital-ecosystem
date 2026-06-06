import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/jadwal_service.dart';
import '../../../shared/models/jadwal_model.dart';
import '../../../core/utils/error_utils.dart';

// ── Service Provider ──────────────────────────

final jadwalServiceProvider = Provider<JadwalService>((ref) {
  return JadwalService();
});

// ── Jadwal State ──────────────────────────────

class JadwalState {
  final List<JadwalModel> jadwal;
  final bool isLoading;
  final String? errorMessage;

  const JadwalState({
    this.jadwal = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  // Jadwal bulan ini
  List<JadwalModel> get jadwalBulanIni {
    final now = DateTime.now();
    return jadwal.where((j) {
      try {
        final tanggal = DateTime.parse(j.tanggal);
        return tanggal.month == now.month && tanggal.year == now.year;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Jadwal mendatang — hari ini dan setelahnya
  List<JadwalModel> get jadwalMendatang {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return jadwal.where((j) {
      try {
        final tanggal = DateTime.parse(j.tanggal);
        final jadwalDate = DateTime(tanggal.year, tanggal.month, tanggal.day);
        return jadwalDate.isAfter(today) || jadwalDate.isAtSameMomentAs(today);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  JadwalState copyWith({
    List<JadwalModel>? jadwal,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JadwalState(
      jadwal: jadwal ?? this.jadwal,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Jadwal Notifier ───────────────────────────

class JadwalNotifier extends StateNotifier<JadwalState> {
  final JadwalService _service;

  JadwalNotifier(this._service) : super(const JadwalState());

  // ── Fetch Jadwal ────────────────────────────

  Future<void> fetchJadwal() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getJadwal();

      // Urutkan dari terdekat
      result.sort((a, b) {
        try {
          return DateTime.parse(a.tanggal).compareTo(DateTime.parse(b.tanggal));
        } catch (_) {
          return 0;
        }
      });

      state = state.copyWith(
        jadwal: result,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorUtils.getCleanErrorMessage(e),
      );
    }
  }
}

// ── Provider ──────────────────────────────────

final jadwalProvider =
    StateNotifierProvider<JadwalNotifier, JadwalState>((ref) {
  return JadwalNotifier(ref.watch(jadwalServiceProvider));
});
