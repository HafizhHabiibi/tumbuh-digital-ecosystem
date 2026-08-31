import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pengukuran_provider.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/insight_card_widget.dart';
import '../../conversational_ai/widgets/chat_entry_card.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';
import '../../../router/app_router.dart';

class DetailPengukuranScreen extends ConsumerWidget {
  final int pengukuranId;

  const DetailPengukuranScreen({super.key, required this.pengukuranId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengukuran = ref.watch(selectedPengukuranProvider);
    final insightState = ref.watch(insightProvider(pengukuranId));

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
            const Text('Detail Pengukuran', style: AppTextStyles.heading3),
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

            // ── Status Antropometri ─────────────
            _buildSectionTitle('Status Antropometri'),
            const SizedBox(height: 12),
            _buildStatusAntropometriCard(pengukuran),
            const SizedBox(height: 16),

            // ── Status Pemantauan ──────────────
            _buildSectionTitle('Status Pemantauan'),
            const SizedBox(height: 12),
            _buildPemantauanCard(pengukuran),
            const SizedBox(height: 16),

            // ── AI Insight ─────────────────────
            _buildSectionTitle('AI Insight'),
            const SizedBox(height: 12),
            InsightCard(
              insightTeks: insightState.insight?.insightTeks,
              createdAt: insightState.insight?.insightGeneratedAt,
              status: insightState.insight?.status,
              isLoading: insightState.isLoading || insightState.isPolling,
              pollingTimedOut: insightState.pollingTimedOut,
              errorMessage: insightState.errorMessage,
              onRefresh: () =>
                  ref.read(insightProvider(pengukuranId).notifier).refresh(),
            ),
            const SizedBox(height: 12),
            ChatEntryCard(
              insightStatus: insightState.insight?.status,
              onPressed: () => context.push(
                AppRoutes.chatPengukuranLocation(
                  pengukuranId,
                  tanggalPengukuran: pengukuran.tanggalUkur,
                ),
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
                'Status BB/TB',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
              ),
              StatusBadge(
                label: pengukuran.statusBbtb,
                type: StatusType.statusAntropometri,
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
                  label: 'Pemantauan',
                  value: formatStatusPemantauan(
                    pengukuran.statusPemantauan,
                  ),
                  isCapitalized: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAntropometriCard(PengukuranModel pengukuran) {
    final statuses = [
      ('BB/U', pengukuran.statusBbu),
      ('TB/U', pengukuran.statusTbu),
      ('BB/TB', pengukuran.statusBbtb),
      ('IMT/U', pengukuran.statusImtu),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: statuses.map((status) {
          return SizedBox(
            width: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.$1, style: AppTextStyles.caption),
                const SizedBox(height: 6),
                StatusBadge(
                  label: status.$2,
                  type: StatusType.statusAntropometri,
                ),
              ],
            ),
          );
        }).toList(),
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

  // ── Status Pemantauan ─────────────────────────

  Widget _buildPemantauanCard(PengukuranModel pengukuran) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          StatusBadge(
            label: pengukuran.statusPemantauan,
            type: StatusType.statusPemantauan,
          ),
          const SizedBox(height: 12),
          Text(
            _getPemantauanDescription(pengukuran.statusPemantauan),
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPemantauanDescription(String status) {
    switch (status.toLowerCase()) {
      case 'rutin':
        return 'Kondisi anak baik, pertahankan pola makan dan aktivitas yang sehat.';
      case 'perlu_perhatian':
        return 'Perlu perhatian lebih, konsultasikan dengan kader atau petugas kesehatan.';
      case 'konsultasi':
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
