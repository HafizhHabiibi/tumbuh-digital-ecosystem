import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pengukuran_provider.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/zscore_card_widget.dart';
import '../../../shared/widgets/insight_card_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class DetailPengukuranScreen extends ConsumerWidget {
  final int pengukuranId;

  const DetailPengukuranScreen({super.key, required this.pengukuranId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengukuran = ref.watch(selectedPengukuranProvider);
    final insightAsync = ref.watch(insightProvider(pengukuranId));

    // Kalau selectedPengukuranProvider null (akses langsung via URL)
    if (pengukuran == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Data pengukuran tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pengukuran', style: AppTextStyles.heading3),
            Text(
              FormatUtils.formatTanggal(pengukuran.tanggalUkur),
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card Ringkasan ─────────────────
            _buildRingkasanCard(pengukuran),
            const SizedBox(height: 16),

            // ── Data Antropometri ──────────────
            _buildSectionTitle('Data Antropometri'),
            const SizedBox(height: 12),
            _buildAntropometriCard(pengukuran),
            const SizedBox(height: 16),

            // ── Z-Score ────────────────────────
            _buildSectionTitle('Z-Score'),
            const SizedBox(height: 12),
            ZScoreRow(
              zscoreBbu: pengukuran.zscoreBbu,
              zscoreTbu: pengukuran.zscoreTbu,
              zscoreBbtb: pengukuran.zscoreBbtb,
            ),
            const SizedBox(height: 16),

            // ── SAW Score ──────────────────────
            _buildSectionTitle('Skor SAW'),
            const SizedBox(height: 12),
            _buildSawCard(pengukuran),
            const SizedBox(height: 16),

            // ── AI Insight ─────────────────────
            _buildSectionTitle('AI Insight'),
            const SizedBox(height: 12),
            insightAsync.when(
              loading: () => const InsightCard(isLoading: true),
              error: (_, __) => const InsightCard(),
              data: (insight) => InsightCard(
                insightTeks: insight?.insightTeks,
                createdAt: insight?.createdAt,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  // ── Ringkasan Card ────────────────────────────

  Widget _buildRingkasanCard(PengukuranModel pengukuran) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Gizi',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
              ),
              StatusBadge(
                label: pengukuran.statusGizi,
                type: StatusType.statusGizi,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRingkasanMetric(
                  label: 'Berat Badan',
                  value: FormatUtils.formatBeratBadan(pengukuran.beratBadan),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildRingkasanMetric(
                  label: 'Tinggi Badan',
                  value: FormatUtils.formatTinggiBadan(pengukuran.tinggiBadan),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildRingkasanMetric(
                  label: 'Kategori',
                  value: pengukuran.kategoriRisiko,
                  isCapitalized: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanMetric({
    required String label,
    required String value,
    bool isCapitalized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            isCapitalized && value.isNotEmpty
                ? value[0].toUpperCase() + value.substring(1)
                : value,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Antropometri Card ─────────────────────────

  Widget _buildAntropometriCard(PengukuranModel pengukuran) {
    final items = [
      _MetricItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Berat Badan',
        value: FormatUtils.formatBeratBadan(pengukuran.beratBadan),
      ),
      _MetricItem(
        icon: Icons.height_outlined,
        label: 'Tinggi Badan',
        value: FormatUtils.formatTinggiBadan(pengukuran.tinggiBadan),
      ),
      if (pengukuran.lingkarKepala != null)
        _MetricItem(
          icon: Icons.radio_button_checked_outlined,
          label: 'Lingkar Kepala',
          value: FormatUtils.formatTinggiBadan(pengukuran.lingkarKepala),
        ),
      if (pengukuran.lingkarLengan != null)
        _MetricItem(
          icon: Icons.accessibility_outlined,
          label: 'Lingkar Lengan',
          value: FormatUtils.formatTinggiBadan(pengukuran.lingkarLengan!),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: items.length,
        itemBuilder: (_, index) {
          final item = items[index];
          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.value,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    Text(item.label, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── SAW Card ──────────────────────────────────

  Widget _buildSawCard(PengukuranModel pengukuran) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skor Akhir', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    pengukuran.skorAkhir.toStringAsFixed(4),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: pengukuran.kategoriRisiko,
                type: StatusType.kategoriRisiko,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar skor SAW
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rendah', style: AppTextStyles.caption),
                  Text('Sedang', style: AppTextStyles.caption),
                  Text('Tinggi', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pengukuran.skorAkhir.clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getSawColor(pengukuran.kategoriRisiko),
                  ),
                  minHeight: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getSawDescription(pengukuran.kategoriRisiko),
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSawColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'rendah':
        return AppColors.risikoRendahText;
      case 'sedang':
        return AppColors.risikoSedangText;
      case 'tinggi':
        return AppColors.risikoTinggiText;
      default:
        return AppColors.primary;
    }
  }

  String _getSawDescription(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'rendah':
        return 'Kondisi anak baik, pertahankan pola makan dan aktivitas yang sehat.';
      case 'sedang':
        return 'Perlu perhatian lebih, konsultasikan dengan kader atau petugas kesehatan.';
      case 'tinggi':
        return 'Segera konsultasikan dengan petugas kesehatan untuk penanganan lebih lanjut.';
      default:
        return '-';
    }
  }
}

// ── Helper Class ──────────────────────────────

class _MetricItem {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
