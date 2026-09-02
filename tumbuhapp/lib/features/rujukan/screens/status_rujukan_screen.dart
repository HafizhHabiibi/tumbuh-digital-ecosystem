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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.rujukanAktif.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'Rujukan Aktif',
              description: state.rujukanAktif.length == 1
                  ? '1 rujukan sedang menunggu atau menerima tindak lanjut.'
                  : '${state.rujukanAktif.length} rujukan sedang menunggu atau menerima tindak lanjut.',
            ),
            const SizedBox(height: 12),
            ..._buildCardList(state.rujukanAktif, isAktif: true),
          ],
          if (state.rujukanAktif.isNotEmpty &&
              state.rujukan.any((item) => item.status == 'selesai'))
            const SizedBox(height: 24),
          if (state.rujukan.any((item) => item.status == 'selesai')) ...[
            _buildSectionHeader(
              title: 'Riwayat Rujukan',
              description: 'Rujukan yang penanganannya telah selesai.',
            ),
            const SizedBox(height: 12),
            ..._buildCardList(
              state.rujukan.where((item) => item.status == 'selesai'),
              isAktif: false,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _refresh() =>
      ref.read(rujukanProvider(widget.anakId).notifier).fetchRujukan();

  Widget _buildSectionHeader({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 4),
        Text(description, style: AppTextStyles.bodySecondary),
      ],
    );
  }

  List<Widget> _buildCardList(
    Iterable<RujukanModel> items, {
    required bool isAktif,
  }) {
    final cards = <Widget>[];
    for (final item in items) {
      if (cards.isNotEmpty) cards.add(const SizedBox(height: 12));
      cards.add(_buildRujukanCard(item, isAktif));
    }
    return cards;
  }

  // ── Rujukan Card ──────────────────────────────

  Widget _buildRujukanCard(RujukanModel rujukan, bool isAktif) {
    return Container(
      key: ValueKey('rujukan-card-${rujukan.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAktif
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardOverview(rujukan),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildStepper(rujukan),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildDetailInfo(rujukan),
        ],
      ),
    );
  }

  Widget _buildCardOverview(RujukanModel rujukan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Pengukuran ${FormatUtils.formatTanggal(rujukan.tanggalUkur)}',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(
              label: rujukan.status,
              type: StatusType.statusRujukan,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(_statusDescription(rujukan.status),
            style: AppTextStyles.bodySecondary),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMeasurementChip(
              'Berat Badan',
              FormatUtils.formatBeratBadan(rujukan.beratBadan),
            ),
            _buildMeasurementChip(
              'Tinggi Badan',
              FormatUtils.formatTinggiBadan(rujukan.tinggiBadan),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Diajukan ${FormatUtils.formatTanggal(rujukan.createdAt)}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'ditangani':
        return 'Rujukan sedang ditangani oleh Puskesmas.';
      case 'selesai':
        return 'Proses penanganan rujukan telah selesai.';
      default:
        return 'Rujukan telah diajukan dan menunggu tindak lanjut Puskesmas.';
    }
  }

  Widget _buildMeasurementChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.caption,
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progres Rujukan',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              _buildStepIndicator(
                steps[index],
                isDone: index <= currentIndex,
                isActive: index == currentIndex,
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final step in steps)
              Expanded(
                child: Text(
                  step.label,
                  style: AppTextStyles.caption.copyWith(
                    color: steps.indexOf(step) <= currentIndex
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: steps.indexOf(step) == currentIndex
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                  textAlign: steps.indexOf(step) == 0
                      ? TextAlign.left
                      : steps.indexOf(step) == steps.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(
    _StepItem step, {
    required bool isDone,
    required bool isActive,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primary : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? AppColors.primaryDark
              : isDone
                  ? AppColors.primary
                  : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Icon(
        step.icon,
        size: 16,
        color: isDone ? Colors.white : AppColors.textSecondary,
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
    final details = <Widget>[];

    void addDetail(IconData icon, String label, String value) {
      if (details.isNotEmpty) details.add(const SizedBox(height: 14));
      details.add(_buildInfoRow(icon: icon, label: label, value: value));
    }

    if (rujukan.catatanKader?.trim().isNotEmpty ?? false) {
      addDetail(Icons.notes_outlined, 'Catatan Kader', rujukan.catatanKader!);
    }
    if (rujukan.catatanPuskesmas?.trim().isNotEmpty ?? false) {
      addDetail(
        Icons.local_hospital_outlined,
        'Tindak Lanjut Puskesmas',
        rujukan.catatanPuskesmas!,
      );
    }
    if (rujukan.ditanganiOleh?.trim().isNotEmpty ?? false) {
      addDetail(
        Icons.person_outline,
        'Ditangani Oleh',
        rujukan.ditanganiOleh!,
      );
    }
    if (rujukan.validatedAt != null) {
      addDetail(
        Icons.event_available_outlined,
        'Mulai Ditangani',
        FormatUtils.formatTanggalJam(rujukan.validatedAt!),
      );
    }
    if (rujukan.completedAt != null) {
      addDetail(
        Icons.task_alt_outlined,
        'Selesai Ditangani',
        FormatUtils.formatTanggalJam(rujukan.completedAt!),
      );
    }

    if (details.isEmpty) {
      return const Text(
        'Belum ada catatan tindak lanjut untuk rujukan ini.',
        style: AppTextStyles.bodySecondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: AppTextStyles.body,
            softWrap: true,
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
