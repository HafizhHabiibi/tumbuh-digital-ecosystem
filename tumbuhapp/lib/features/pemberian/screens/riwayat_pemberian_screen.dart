import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pemberian_provider.dart';
import '../../../shared/models/pemberian_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
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
        title: Text('Riwayat Pemberian', style: AppTextStyles.heading3),
      ),
      body: Column(
        children: [
          // ── Filter Chips ───────────────────
          _buildFilterChips(state),

          // ── Content ────────────────────────
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────

  Widget _buildFilterChips(PemberianState state) {
    final filters = [
      {'value': 'semua', 'label': 'Semua'},
      {'value': 'vitamin_a', 'label': 'Vitamin A'},
      {'value': 'obat_cacing', 'label': 'Obat Cacing'},
      {'value': 'pmt', 'label': 'PMT'},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final filter = filters[index];
            final isActive = state.activeFilter == filter['value'];

            return GestureDetector(
              onTap: () => ref
                  .read(pemberianProvider.notifier)
                  .setFilter(filter['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  filter['label']!,
                  style: AppTextStyles.body.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
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
      return const EmptyPemberian();
    }

    // Kelompokkan per bulan
    final grouped = _groupByMonth(state.filtered);

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
              Text(bulan, style: AppTextStyles.heading3),
            ],
          ),
        ),

        // Items
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildPemberianItem(item),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Pemberian Item ────────────────────────────

  Widget _buildPemberianItem(PemberianModel item) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icon jenis
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getJenisBgColor(item.jenis),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getJenisIcon(item.jenis),
              color: _getJenisColor(item.jenis),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama & badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.namaItem,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: item.jenis,
                      type: StatusType.jenisPemberian,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Dosis & tanggal
                Row(
                  children: [
                    if (item.dosis != null) ...[
                      Icon(
                        Icons.colorize_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.dosis!,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      FormatUtils.formatTanggal(item.tanggalPemberian),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Dicatat oleh
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dicatat oleh ${item.dicatatOleh}',
                      style: AppTextStyles.caption,
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
