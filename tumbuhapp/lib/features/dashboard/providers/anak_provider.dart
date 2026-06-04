import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/anak_service.dart';
import '../../../shared/models/anak_model.dart';

// ── Service Provider ──────────────────────────

final anakServiceProvider = Provider<AnakService>((ref) {
  return AnakService();
});

// ── Daftar Anak Provider ──────────────────────

final daftarAnakProvider = FutureProvider<List<AnakModel>>((ref) async {
  return ref.watch(anakServiceProvider).getDaftarAnak();
});

// ── Selected Anak Provider ────────────────────
// Menyimpan anak yang sedang dipilih di dashboard

final selectedAnakProvider = StateProvider<AnakModel?>((ref) {
  return null;
});

// ── Selected Anak Index ───────────────────────
// Untuk horizontal card selector di dashboard

final selectedAnakIndexProvider = StateProvider<int>((ref) {
  return 0;
});

// ── Detail Anak Provider ──────────────────────

final detailAnakProvider =
    FutureProvider.family<AnakModel, String>((ref, anakId) async {
  return ref.watch(anakServiceProvider).getDetailAnak(anakId);
});

// ── Auto Select Anak Pertama ──────────────────
// Otomatis pilih anak pertama saat daftar anak berhasil dimuat

final autoSelectAnakProvider = Provider<void>((ref) {
  final daftarAnakAsync = ref.watch(daftarAnakProvider);

  daftarAnakAsync.whenData((daftarAnak) {
    if (daftarAnak.isNotEmpty) {
      final selected = ref.read(selectedAnakProvider);
      if (selected == null) {
        Future.microtask(() {
          if (ref.read(selectedAnakProvider) == null) {
            ref.read(selectedAnakProvider.notifier).state = daftarAnak.first;
          }
        });
      }
    }
  });
});
