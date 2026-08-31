import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pemberian_provider.dart';
import '../../../shared/models/pemberian_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class RiwayatPemberianScreen extends ConsumerStatefulWidget {
  final String anakId;

  const RiwayatPemberianScreen({super.key, required this.anakId});

  @override
  ConsumerState<RiwayatPemberianScreen> createState() =>
      _RiwayatPemberianScreenState();
}

class _RiwayatPemberianScreenState
    extends ConsumerState<RiwayatPemberianScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pemberianProvider.notifier).fetchPemberian(widget.anakId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pemberianProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Riwayat Pemberian', style: AppTextStyles.heading3),
      ),
      body: Column(
        children: [
          if (!state.isLoading &&
              state.errorMessage == null &&
              state.riwayat.isNotEmpty)
            _buildHistoryHeader(state),

          // ── Content ────────────────────────
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────

  Widget _buildHistoryHeader(PemberianState state) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tampilkan berdasarkan jenis',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterChips(state),
        ],
      ),
    );
  }

  Widget _buildFilterChips(PemberianState state) {
    final filters = [
      {'value': 'semua', 'label': 'Semua'},
      {'value': 'vitamin_a', 'label': 'Vitamin A'},
      {'value': 'obat_cacing', 'label': 'Obat Cacing'},
      {'value': 'pmt', 'label': 'PMT'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        key: const ValueKey('pemberian-filter-list'),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final value = filter['value']!;
          final isActive = state.activeFilter == value;
          final count = value == 'semua'
              ? state.riwayat.length
              : state.riwayat.where((item) => item.sesuaiFilter(value)).length;

          return ChoiceChip(
            selected: isActive,
            showCheckmark: false,
            label: Text('${filter['label']} ($count)'),
            onSelected: (_) =>
                ref.read(pemberianProvider.notifier).setFilter(value),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelStyle: AppTextStyles.body.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  // ── Content ───────────────────────────────────

  Widget _buildContent(PemberianState state) {
    if (state.isLoading) {
      return const ShimmerList(itemCount: 6, itemHeight: 80);
    }

    if (state.errorMessage != null) {
      return ErrorStateWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(pemberianProvider.notifier).fetchPemberian(widget.anakId),
      );
    }

    if (state.filtered.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(pemberianProvider.notifier).fetchPemberian(widget.anakId),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: state.riwayat.isEmpty
                  ? const EmptyPemberian()
                  : _FilteredEmptyState(
                      categoryLabel: _activeFilterLabel(state.activeFilter),
                    ),
            ),
          ],
        ),
      );
    }

    // Kelompokkan per bulan
    final sorted = [...state.filtered]
      ..sort((a, b) => b.tanggalPemberian.compareTo(a.tanggalPemberian));
    final grouped = _groupByMonth(sorted);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(pemberianProvider.notifier).fetchPemberian(widget.anakId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (_, index) {
          final entry = grouped.entries.elementAt(index);
          return _buildMonthGroup(entry.key, entry.value);
        },
      ),
    );
  }

  String _activeFilterLabel(String filter) {
    return switch (filter) {
      'vitamin_a' => 'Vitamin A',
      'obat_cacing' => 'Obat Cacing',
      'pmt' => 'PMT',
      _ => 'Pemberian',
    };
  }

  // ── Group by Month ────────────────────────────

  Map<String, List<PemberianModel>> _groupByMonth(
      List<PemberianModel> riwayat) {
    final Map<String, List<PemberianModel>> grouped = {};

    for (final item in riwayat) {
      try {
        final date = DateTime.parse(item.tanggalPemberian);
        final key = '${_getNamaBulan(date.month)} ${date.year}';
        grouped.putIfAbsent(key, () => []).add(item);
      } catch (_) {
        grouped.putIfAbsent('Lainnya', () => []).add(item);
      }
    }

    return grouped;
  }

  String _getNamaBulan(int bulan) {
    const bulanList = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulanList[bulan - 1];
  }

  // ── Month Group ───────────────────────────────

  Widget _buildMonthGroup(String bulan, List<PemberianModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header bulan
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(bulan, style: AppTextStyles.heading3)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} pemberian',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPemberianItem(item),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Pemberian Item ────────────────────────────

  Widget _buildPemberianItem(PemberianModel item) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    );

    return Material(
      key: ValueKey('pemberian-${item.id}'),
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getJenisBgColor(item.kategori).withValues(alpha: 0.72),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getJenisIcon(item.kategori),
                    color: _getJenisColor(item.kategori),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaItem,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: _getJenisColor(item.kategori),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              FormatUtils.formatTanggal(
                                item.tanggalPemberian,
                              ),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasText(item.dosis))
                  _buildDetailRow(
                    icon: Icons.colorize_outlined,
                    label: 'Dosis',
                    value: item.dosis!.trim(),
                  ),
                if (_hasText(item.dosis) && _hasText(item.keterangan))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
                if (_hasText(item.keterangan))
                  _buildDetailRow(
                    icon: Icons.notes_outlined,
                    label: 'Catatan',
                    value: item.keterangan!.trim(),
                  ),
                if (_hasText(item.dosis) || _hasText(item.keterangan))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Dicatat oleh ${_hasText(item.dicatatOleh) ? item.dicatatOleh.trim() : 'Petugas Posyandu'}',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 58,
          child: Text(label, style: AppTextStyles.caption),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  // ── Helpers ───────────────────────────────────

  IconData _getJenisIcon(String jenis) {
    switch (jenis) {
      case 'vitamin_a':
        return Icons.medication_outlined;
      case 'obat_cacing':
        return Icons.pest_control_outlined;
      case 'pmt':
        return Icons.restaurant_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'vitamin_a':
        return AppColors.vitaminAText;
      case 'obat_cacing':
        return AppColors.obatCacingText;
      case 'pmt':
        return AppColors.pmtText;
      default:
        return AppColors.primary;
    }
  }

  Color _getJenisBgColor(String jenis) {
    switch (jenis) {
      case 'vitamin_a':
        return AppColors.vitaminABg;
      case 'obat_cacing':
        return AppColors.obatCacingBg;
      case 'pmt':
        return AppColors.pmtBg;
      default:
        return AppColors.primarySurface;
    }
  }
}

class _FilteredEmptyState extends StatelessWidget {
  final String categoryLabel;

  const _FilteredEmptyState({required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_toggle_off_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum Ada Riwayat $categoryLabel',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 6),
            const Text(
              'Catatan akan muncul setelah pemberian dilakukan oleh petugas Posyandu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
