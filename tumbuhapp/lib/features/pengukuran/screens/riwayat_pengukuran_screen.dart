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
        title: const Text('Riwayat Pengukuran', style: AppTextStyles.heading3),
      ),
      body: riwayatAsync.when(
        loading: () => const ShimmerList(itemCount: 4, itemHeight: 220),
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final pengukuran = riwayat[index];
                return _buildItem(
                  context,
                  ref,
                  pengukuran,
                  isTerbaru: index == 0,
                );
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
    PengukuranModel pengukuran, {
    required bool isTerbaru,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    );

    return Material(
      key: ValueKey('riwayat-pengukuran-${pengukuran.id}'),
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(selectedPengukuranProvider.notifier).state = pengukuran;
          context.push('/pengukuran/${pengukuran.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FormatUtils.formatTanggal(pengukuran.tanggalUkur),
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Usia saat diukur: ${_formatUsia(pengukuran.usiaBulan)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (isTerbaru)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Terbaru',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ── Metrik utama ───────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Berat Badan',
                      value:
                          FormatUtils.formatBeratBadan(pengukuran.beratBadan),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetric(
                      icon: Icons.height_outlined,
                      label: 'Tinggi Badan',
                      value:
                          FormatUtils.formatTinggiBadan(pengukuran.tinggiBadan),
                    ),
                  ),
                ],
              ),
            ),

            // ── Ringkasan status ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(
                      label: 'Status Gizi',
                      badge: StatusBadge(
                        label: pengukuran.statusBbtb,
                        type: StatusType.statusAntropometri,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    _buildStatusRow(
                      label: 'Saran Pemantauan',
                      badge: StatusBadge(
                        label: pengukuran.statusPemantauan,
                        type: StatusType.statusPemantauan,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Aksi ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Lihat detail pengukuran',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({required String label, required Widget badge}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        badge,
      ],
    );
  }

  String _formatUsia(int totalBulan) {
    if (totalBulan < 12) return '$totalBulan bulan';

    final tahun = totalBulan ~/ 12;
    final bulan = totalBulan % 12;
    return bulan == 0 ? '$tahun tahun' : '$tahun tahun $bulan bulan';
  }
}
