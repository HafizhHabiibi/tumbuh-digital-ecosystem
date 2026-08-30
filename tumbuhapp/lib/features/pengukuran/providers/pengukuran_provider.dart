import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_utils.dart';
import '../../../shared/models/insight_model.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/models/pengukuran_response.dart';
import '../data/pengukuran_service.dart';

final pengukuranServiceProvider = Provider<PengukuranService>((ref) {
  return PengukuranService();
});

final riwayatPengukuranProvider =
    FutureProvider.family<PengukuranResponse, String>((ref, anakId) async {
  return ref.watch(pengukuranServiceProvider).getPengukuran(anakId);
});

final insightProvider = StateNotifierProvider.autoDispose
    .family<InsightController, InsightViewState, int>((ref, pengukuranId) {
  final controller = InsightController(
    pengukuranId: pengukuranId,
    gateway: ref.watch(pengukuranServiceProvider),
  );
  Future.microtask(controller.load);
  return controller;
});

class InsightViewState {
  final InsightModel? insight;
  final bool isLoading;
  final bool isPolling;
  final bool pollingTimedOut;
  final String? errorMessage;

  const InsightViewState({
    this.insight,
    this.isLoading = false,
    this.isPolling = false,
    this.pollingTimedOut = false,
    this.errorMessage,
  });
}

typedef InsightDelay = Future<void> Function(Duration duration);
typedef InsightNow = DateTime Function();

class InsightController extends StateNotifier<InsightViewState> {
  final int pengukuranId;
  final InsightGateway gateway;
  final Duration pollInterval;
  final Duration maxPollingDuration;
  final InsightDelay delay;
  final InsightNow now;

  int _generation = 0;

  InsightController({
    required this.pengukuranId,
    required this.gateway,
    this.pollInterval = const Duration(seconds: 3),
    this.maxPollingDuration = const Duration(minutes: 1),
    InsightDelay? delay,
    InsightNow? now,
  })  : delay = delay ?? Future.delayed,
        now = now ?? DateTime.now,
        super(const InsightViewState());

  Future<void> load() async {
    final generation = ++_generation;
    final deadline = now().add(maxPollingDuration);
    state = InsightViewState(
      insight: state.insight,
      isLoading: state.insight == null,
    );

    while (generation == _generation) {
      try {
        final insight = await gateway.getInsight(pengukuranId);
        if (generation != _generation) return;

        if (!insight.isInProgress) {
          state = InsightViewState(insight: insight);
          return;
        }
        if (!now().isBefore(deadline)) {
          state = InsightViewState(
            insight: insight,
            pollingTimedOut: true,
          );
          return;
        }
        state = InsightViewState(insight: insight, isPolling: true);
        await delay(pollInterval);
      } catch (error) {
        if (generation != _generation) return;
        state = InsightViewState(
          insight: state.insight,
          errorMessage: ErrorUtils.getCleanErrorMessage(error),
        );
        return;
      }
    }
  }

  Future<void> refresh() => load();

  @override
  void dispose() {
    _generation += 1;
    super.dispose();
  }
}

final selectedPengukuranProvider = StateProvider<PengukuranModel?>((ref) {
  return null;
});

final pengukuranTerakhirProvider =
    FutureProvider.family<PengukuranModel?, String>((ref, anakId) async {
  final result =
      await ref.watch(pengukuranServiceProvider).getPengukuran(anakId);
  return result.riwayat.isNotEmpty ? result.riwayat.first : null;
});
