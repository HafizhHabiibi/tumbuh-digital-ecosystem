import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pengukuran_service.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/models/insight_model.dart';
import '../../../shared/models/pengukuran_response.dart';

// ── Service Provider ──────────────────────────

final pengukuranServiceProvider = Provider<PengukuranService>((ref) {
  return PengukuranService();
});

// ── Riwayat Pengukuran Provider ───────────────

final riwayatPengukuranProvider =
    FutureProvider.family<PengukuranResponse, String>((ref, anakId) async {
  return ref.watch(pengukuranServiceProvider).getPengukuran(anakId);
});

// ── Insight Provider ──────────────────────────

final insightProvider =
    FutureProvider.family<InsightModel?, int>((ref, pengukuranId) async {
  return ref.watch(pengukuranServiceProvider).getInsight(pengukuranId);
});

// ── Selected Pengukuran Provider ──────────────
// Menyimpan pengukuran yang sedang dilihat detail

final selectedPengukuranProvider = StateProvider<PengukuranModel?>((ref) {
  return null;
});

// ── Pengukuran Terakhir Provider ──────────────
// Dipakai di dashboard untuk AI Insight preview

final pengukuranTerakhirProvider =
    FutureProvider.family<PengukuranModel?, String>((ref, anakId) async {
  final result =
      await ref.watch(pengukuranServiceProvider).getPengukuran(anakId);

  return result.riwayat.isNotEmpty ? result.riwayat.first : null;
});
