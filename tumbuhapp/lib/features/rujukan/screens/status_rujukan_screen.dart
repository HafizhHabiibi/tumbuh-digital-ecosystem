import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rujukan_provider.dart';
import '../../../shared/models/rujukan_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class StatusRujukanScreen extends ConsumerStatefulWidget {
  final String anakId;

  const StatusRujukanScreen({super.key, required this.anakId});

  @override
  ConsumerState<StatusRujukanScreen> createState() =>
      _StatusRujukanScreenState();
}

class _StatusRujukanScreenState extends ConsumerState<StatusRujukanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rujukanProvider.notifier).fetchRujukan(widget.anakId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rujukanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Status Rujukan', style: AppTextStyles.heading3),
      ),
      body: _buildContent(state),
    );
  }

  // ── Content ───────────────────────────────────

  Widget _buildContent(RujukanState state) {
    if (state.isLoading) {
      return const ShimmerList(itemCount: 3, itemHeight: 200);
    }

    if (state.errorMessage != null) {
      return ErrorStateWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(rujukanProvider.notifier).fetchRujukan(widget.anakId),
      );
    }

    if (state.rujukan.isEmpty) {
      return const EmptyRujukan();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(rujukanProvider.notifier).fetchRujukan(widget.anakId),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.rujukan.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final rujukan = state.rujukan[index];
          final isAktif = state.rujukanAktif.contains(rujukan);
          return _buildRujukanCard(rujukan, isAktif);
        },
      ),
    );
  }

  // ── Rujukan Card ──────────────────────────────

  Widget _buildRujukanCard(RujukanModel rujukan, bool isAktif) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAktif ? AppColors.primary : AppColors.border,
          width: isAktif ? 2 : 1,
        ),
        boxShadow: isAktif
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────
          _buildCardHeader(rujukan, isAktif),

          // ── Stepper Status ────────────────
          _buildStepper(rujukan),

          // ── Detail Info ───────────────────
          _buildDetailInfo(rujukan),
        ],
      ),
    );
  }

  // ── Card Header ───────────────────────────────

  Widget _buildCardHeader(RujukanModel rujukan, bool isAktif) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAktif ? AppColors.primarySurface : AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAktif
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: isAktif ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAktif ? 'Rujukan Aktif' : 'Riwayat Rujukan',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isAktif ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    FormatUtils.formatTanggal(rujukan.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          StatusBadge(
            label: rujukan.status,
            type: StatusType.statusRujukan,
          ),
        ],
      ),
    );
  }

  // ── Stepper ───────────────────────────────────

  Widget _buildStepper(RujukanModel rujukan) {
    final steps = [
      _StepItem(
        label: 'Diajukan',
        status: 'diajukan',
        icon: Icons.send_outlined,
      ),
      _StepItem(
        label: 'Diterima',
        status: 'diterima',
        icon: Icons.check_circle_outline,
      ),
      _StepItem(
        label: 'Penanganan',
        status: 'dalam_penanganan',
        icon: Icons.medical_services_outlined,
      ),
      _StepItem(
        label: 'Selesai',
        status: 'selesai',
        icon: Icons.task_alt_outlined,
      ),
    ];

    // Kalau ditolak tampilkan stepper berbeda
    if (rujukan.status == 'ditolak') {
      return _buildDitolakStepper();
    }

    final currentIndex = _getStepIndex(rujukan.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isDone = index <= currentIndex;
          final isActive = index == currentIndex;
          final isLast = index == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Step circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              isDone ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isDone ? AppColors.primary : AppColors.border,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          step.icon,
                          size: 16,
                          color:
                              isDone ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Step label
                      Text(
                        step.label,
                        style: AppTextStyles.caption.copyWith(
                          color: isDone
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: index < currentIndex
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDitolakStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.rujukanDitolakBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rujukanDitolakText),
            ),
            child: Icon(
              Icons.cancel_outlined,
              size: 16,
              color: AppColors.rujukanDitolakText,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rujukan Ditolak',
            style: AppTextStyles.body.copyWith(
              color: AppColors.rujukanDitolakText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getStepIndex(String status) {
    switch (status) {
      case 'diajukan':
        return 0;
      case 'diterima':
        return 1;
      case 'dalam_penanganan':
        return 2;
      case 'selesai':
        return 3;
      default:
        return 0;
    }
  }

  // ── Detail Info ───────────────────────────────

  Widget _buildDetailInfo(RujukanModel rujukan) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),

          // Catatan Kader
          _buildInfoRow(
            icon: Icons.note_outlined,
            label: 'Catatan Kader',
            value: rujukan.catatanKader,
          ),
          const SizedBox(height: 8),

          // Catatan Puskesmas
          if (rujukan.catatanPuskesmas != null) ...[
            _buildInfoRow(
              icon: Icons.local_hospital_outlined,
              label: 'Catatan Puskesmas',
              value: rujukan.catatanPuskesmas!,
            ),
            const SizedBox(height: 8),
          ],

          // Ditangani oleh
          if (rujukan.ditanganiOleh != null) ...[
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Ditangani Oleh',
              value: rujukan.ditanganiOleh!,
            ),
            const SizedBox(height: 8),
          ],

          // Tanggal selesai
          if (rujukan.validatedAt != null)
            _buildInfoRow(
              icon: Icons.event_available_outlined,
              label: 'Tanggal Selesai',
              value: FormatUtils.formatTanggal(rujukan.validatedAt!),
            ),

          // Skor SAW
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.analytics_outlined,
            label: 'Skor SAW',
            value:
                '${rujukan.skorAkhir.toStringAsFixed(4)} (${rujukan.kategoriRisiko})',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helper Class ──────────────────────────────

class _StepItem {
  final String label;
  final String status;
  final IconData icon;

  const _StepItem({
    required this.label,
    required this.status,
    required this.icon,
  });
}
