import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  Widget build(BuildContext context) {
    final state = ref.watch(rujukanProvider(widget.anakId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Status Rujukan', style: AppTextStyles.heading3),
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
        onRetry: _refresh,
      );
    }

    if (state.rujukan.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            key: const ValueKey('empty-rujukan-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const EmptyRujukan(),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
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

  Future<void> _refresh() =>
      ref.read(rujukanProvider(widget.anakId).notifier).fetchRujukan();

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
                  color: AppColors.primary.withValues(alpha: 0.1),
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
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isAktif
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: isAktif ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAktif ? 'Rujukan Aktif' : 'Riwayat Rujukan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAktif
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Diajukan ${FormatUtils.formatTanggal(rujukan.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: StatusBadge(
              label: rujukan.status,
              type: StatusType.statusRujukan,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stepper ───────────────────────────────────

  Widget _buildStepper(RujukanModel rujukan) {
    final steps = [
      const _StepItem(
        label: 'Diajukan',
        icon: Icons.send_outlined,
      ),
      const _StepItem(
        label: 'Ditangani',
        icon: Icons.medical_services_outlined,
      ),
      const _StepItem(
        label: 'Selesai',
        icon: Icons.task_alt_outlined,
      ),
    ];

    final currentIndex = _getStepIndex(rujukan.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.expand((entry) {
          final index = entry.key;
          final step = entry.value;
          final isDone = index <= currentIndex;
          final isActive = index == currentIndex;
          final isLast = index == steps.length - 1;

          final indicator = Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 36 : 32,
                  height: isActive ? 36 : 32,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primaryDark
                          : isDone
                              ? AppColors.primary
                              : AppColors.border,
                      width: isActive ? 3 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    step.icon,
                    size: 16,
                    color: isDone ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isDone ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );

          if (isLast) return [indicator];
          return [
            indicator,
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 16),
                color:
                    index < currentIndex ? AppColors.primary : AppColors.border,
              ),
            ),
          ];
        }).toList(),
      ),
    );
  }

  int _getStepIndex(String status) {
    switch (status) {
      case 'diajukan':
        return 0;
      case 'ditangani':
        return 1;
      case 'selesai':
        return 2;
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

          _buildInfoRow(
            icon: Icons.monitor_weight_outlined,
            label: 'Dasar Rujukan',
            value:
                'Pengukuran ${FormatUtils.formatTanggal(rujukan.tanggalUkur)}',
          ),
          const SizedBox(height: 8),

          // Alasan atau catatan dari kader
          if (rujukan.catatanKader?.trim().isNotEmpty ?? false) ...[
            _buildInfoRow(
              icon: Icons.note_outlined,
              label: 'Alasan / Catatan Kader',
              value: rujukan.catatanKader!,
            ),
            const SizedBox(height: 8),
          ],

          // Tindak lanjut dari Puskesmas
          if (rujukan.catatanPuskesmas?.trim().isNotEmpty ?? false) ...[
            _buildInfoRow(
              icon: Icons.local_hospital_outlined,
              label: 'Tindak Lanjut Puskesmas',
              value: rujukan.catatanPuskesmas!,
            ),
            const SizedBox(height: 8),
          ],

          // Ditangani oleh
          if (rujukan.ditanganiOleh?.trim().isNotEmpty ?? false) ...[
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Ditangani Oleh',
              value: rujukan.ditanganiOleh!,
            ),
            const SizedBox(height: 8),
          ],

          // Waktu pertama kali rujukan ditangani/divalidasi
          if (rujukan.validatedAt != null)
            _buildInfoRow(
              icon: Icons.event_available_outlined,
              label: 'Mulai Ditangani',
              value: FormatUtils.formatTanggalJam(rujukan.validatedAt!),
            ),

          if (rujukan.validatedAt != null && rujukan.completedAt != null)
            const SizedBox(height: 8),

          if (rujukan.completedAt != null)
            _buildInfoRow(
              icon: Icons.task_alt_outlined,
              label: 'Selesai Ditangani',
              value: FormatUtils.formatTanggalJam(rujukan.completedAt!),
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
  final IconData icon;

  const _StepItem({
    required this.label,
    required this.icon,
  });
}
