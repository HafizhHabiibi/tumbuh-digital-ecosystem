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
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Pengukuran', style: AppTextStyles.heading3),
            const SizedBox(height: 4),
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
            // ── Data Antropometri ──────────────
            _buildSectionTitle('Data Antropometri'),
            const SizedBox(height: 12),
            _buildAntropometriCard(pengukuran),
            const SizedBox(height: 16),

            // ── Status Antropometri ─────────────
            _buildSectionTitle('Status Antropometri'),
            const SizedBox(height: 4),
            const Text(
              'Setiap indikator membandingkan berat, tinggi, atau IMT sesuai acuan pertumbuhan anak.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            _buildStatusAntropometriCard(pengukuran),
            const SizedBox(height: 16),

            // ── Status Pemantauan ──────────────
            _buildSectionTitle('Status Pemantauan'),
            const SizedBox(height: 12),
            _buildPemantauanCard(pengukuran),
            const SizedBox(height: 16),

            // ── AI Insight Perkembangan ────────
            _buildSectionTitle('AI Insight Perkembangan'),
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

  Widget _buildStatusAntropometriCard(PengukuranModel pengukuran) {
    final statuses = [
      _StatusAntropometriItem(
        kode: 'BB/U',
        label: 'Berat badan menurut usia',
        status: pengukuran.statusBbu,
      ),
      _StatusAntropometriItem(
        kode: 'TB/U',
        label: 'Tinggi badan menurut usia',
        status: pengukuran.statusTbu,
      ),
      _StatusAntropometriItem(
        kode: 'BB/TB',
        label: 'Berat badan menurut tinggi badan',
        status: pengukuran.statusBbtb,
      ),
      _StatusAntropometriItem(
        kode: 'IMT/U',
        label: 'Indeks massa tubuh menurut usia',
        status: pengukuran.statusImtu,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: statuses.indexed.map((entry) {
          final index = entry.$1;
          final status = entry.$2;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < statuses.length - 1 ? 10 : 0,
            ),
            child: Container(
              key: ValueKey(
                'status-antropometri-${status.kode.toLowerCase().replaceAll('/', '')}',
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      status.kode,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.label,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: status.status,
                          type: StatusType.statusAntropometri,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
          mainAxisExtent: 76,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(
            label: pengukuran.statusPemantauan,
            type: StatusType.statusPemantauan,
          ),
          const SizedBox(height: 12),
          Text(
            _getPemantauanDescription(pengukuran.statusPemantauan),
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }

  String _getPemantauanDescription(String status) {
    switch (status.toLowerCase()) {
      case 'rutin':
        return 'Pantau pola makan dan pertumbuhan anak secara rutin. Pertahankan kebiasaan sehat yang sudah berjalan.';
      case 'perlu_perhatian':
        return 'Pantau pola makan dan pertumbuhan anak secara rutin. Konsultasikan dengan kader bila ada kekhawatiran.';
      case 'konsultasi':
        return 'Konsultasikan hasil pertumbuhan anak dengan kader atau petugas kesehatan untuk mendapatkan arahan lebih lanjut.';
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

class _StatusAntropometriItem {
  final String kode;
  final String label;
  final String status;

  const _StatusAntropometriItem({
    required this.kode,
    required this.label,
    required this.status,
  });
}
