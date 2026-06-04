import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pengukuran_provider.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class RiwayatPengukuranScreen extends ConsumerWidget {
  final String anakId;

  const RiwayatPengukuranScreen({super.key, required this.anakId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatAsync = ref.watch(riwayatPengukuranProvider(anakId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Riwayat Pengukuran', style: AppTextStyles.heading3),
        actions: [
          // Tombol grafik
          IconButton(
            icon: const Icon(
              Icons.show_chart,
              color: AppColors.primary,
            ),
            onPressed: () => context.push('/anak/$anakId/grafik'),
          ),
        ],
      ),
      body: riwayatAsync.when(
        loading: () => const ShimmerList(itemCount: 5, itemHeight: 100),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(riwayatPengukuranProvider(anakId)),
        ),
        data: (data) {
          final riwayat = data.riwayat;

          if (riwayat.isEmpty) return const EmptyPengukuran();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                ref.refresh(riwayatPengukuranProvider(anakId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: riwayat.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final pengukuran = riwayat[index];
                return _buildItem(context, ref, pengukuran);
              },
            ),
          );
        },
      ),
    );
  }

  // ── Item Pengukuran ───────────────────────────

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    PengukuranModel pengukuran,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedPengukuranProvider.notifier).state = pengukuran;
        context.push('/pengukuran/${pengukuran.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Tanggal & Status ───────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      FormatUtils.formatTanggal(pengukuran.tanggalUkur),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                StatusBadge(
                  label: pengukuran.statusGizi,
                  type: StatusType.statusGizi,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // ── BB & TB ───────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Berat Badan',
                    value: FormatUtils.formatBeratBadan(pengukuran.beratBadan),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.height_outlined,
                    label: 'Tinggi Badan',
                    value:
                        FormatUtils.formatTinggiBadan(pengukuran.tinggiBadan),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.analytics_outlined,
                    label: 'Skor SAW',
                    value: pengukuran.skorAkhir.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Kategori Risiko & Arrow ────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(
                  label: pengukuran.kategoriRisiko,
                  type: StatusType.kategoriRisiko,
                ),
                Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Metric Widget ─────────────────────────────

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
