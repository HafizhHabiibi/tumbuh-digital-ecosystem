import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rujukan_service.dart';
import '../../../shared/models/rujukan_model.dart';
import '../../../shared/models/anak_model.dart';
import '../../../core/utils/error_utils.dart';

// ── Service Provider ──────────────────────────

final rujukanServiceProvider = Provider<RujukanService>((ref) {
  return RujukanService();
});

// ── Rujukan State ─────────────────────────────

class RujukanState {
  final AnakModel? anak;
  final List<RujukanModel> rujukan;
  final bool isLoading;
  final String? errorMessage;

  const RujukanState({
    this.anak,
    this.rujukan = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  // Rujukan aktif — diajukan atau sedang ditangani
  List<RujukanModel> get rujukanAktif =>
      rujukan.where((r) => r.status != 'selesai').toList();

  // Riwayat — semua rujukan
  List<RujukanModel> get riwayat => rujukan;

  bool get hasAktif => rujukanAktif.isNotEmpty;

  RujukanState copyWith({
    AnakModel? anak,
    List<RujukanModel>? rujukan,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RujukanState(
      anak: anak ?? this.anak,
      rujukan: rujukan ?? this.rujukan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ── Rujukan Notifier ──────────────────────────

class RujukanNotifier extends StateNotifier<RujukanState> {
  final RujukanService _service;
  final String _anakId;

  RujukanNotifier(this._service, this._anakId) : super(const RujukanState());

  // ── Fetch Rujukan ───────────────────────────

  Future<void> fetchRujukan() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _service.getRujukan(_anakId);

      state = state.copyWith(
        anak: result['anak'] as AnakModel,
        rujukan: result['rujukan'] as List<RujukanModel>,
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

final rujukanProvider = StateNotifierProvider.autoDispose
    .family<RujukanNotifier, RujukanState, String>((ref, anakId) {
  final notifier = RujukanNotifier(
    ref.watch(rujukanServiceProvider),
    anakId,
  );
  Future.microtask(notifier.fetchRujukan);
  return notifier;
});
