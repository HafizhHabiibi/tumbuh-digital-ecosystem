import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notifikasi_provider.dart';
import '../../../shared/models/notifikasi_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class NotifikasiScreen extends ConsumerStatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  ConsumerState<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends ConsumerState<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notifikasiProvider.notifier).fetchNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notifikasiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          // ── Filter Chips ───────────────────
          _buildFilterChips(state),

          // ── Content ────────────────────────
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────

  PreferredSizeWidget _buildAppBar(NotifikasiState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifikasi', style: AppTextStyles.heading3),
          if (state.belumDibaca > 0)
            Text(
              '${state.belumDibaca} belum dibaca',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
      actions: [
        if (state.belumDibaca > 0)
          TextButton(
            onPressed: () => _bacaSemua(),
            child: Text(
              'Baca Semua',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────

  Widget _buildFilterChips(NotifikasiState state) {
    final filters = [
      {'value': 'semua', 'label': 'Semua'},
      {'value': 'jadwal', 'label': 'Jadwal'},
      {'value': 'rujukan', 'label': 'Rujukan'},
      {'value': 'pengingat', 'label': 'Pengingat'},
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
                  .read(notifikasiProvider.notifier)
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

  Widget _buildContent(NotifikasiState state) {
    if (state.isLoading) {
      return const ShimmerList(itemCount: 6, itemHeight: 80);
    }

    if (state.errorMessage != null) {
      return ErrorStateWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(notifikasiProvider.notifier).fetchNotifikasi(),
      );
    }

    if (state.filtered.isEmpty) {
      return const EmptyNotifikasi();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(notifikasiProvider.notifier).fetchNotifikasi(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final notifikasi = state.filtered[index];
          return _buildNotifikasiItem(notifikasi);
        },
      ),
    );
  }

  // ── Notifikasi Item ───────────────────────────

  Widget _buildNotifikasiItem(NotifikasiModel notifikasi) {
    final sudahDibaca = notifikasi.sudahDibaca;

    return Dismissible(
      key: Key('notif_${notifikasi.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.done_all,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        if (!sudahDibaca) {
          await ref
              .read(notifikasiProvider.notifier)
              .bacaNotifikasi(notifikasi.id);
        }
        return false; // Tidak benar-benar dismiss
      },
      child: GestureDetector(
        onTap: () {
          if (!sudahDibaca) {
            ref.read(notifikasiProvider.notifier).bacaNotifikasi(notifikasi.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sudahDibaca ? AppColors.background : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: sudahDibaca ? Colors.transparent : AppColors.primary,
                width: 3,
              ),
            ),
            boxShadow: sudahDibaca
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconBgColor(notifikasi.tipe),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIcon(notifikasi.tipe),
                  color: _getIconColor(notifikasi.tipe),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // ── Konten ────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      notifikasi.judul,
                      style: AppTextStyles.body.copyWith(
                        fontWeight:
                            sudahDibaca ? FontWeight.normal : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Pesan
                    Text(
                      notifikasi.pesan,
                      style: AppTextStyles.bodySecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Waktu
                    Text(
                      FormatUtils.formatWaktuRelatif(notifikasi.sentAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Indikator Belum Dibaca ────
              if (!sudahDibaca)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Icon per Tipe ─────────────────────────────

  IconData _getIcon(String tipe) {
    switch (tipe) {
      case 'jadwal':
        return Icons.calendar_month_outlined;
      case 'rujukan':
        return Icons.local_hospital_outlined;
      case 'pengingat':
        return Icons.alarm_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String tipe) {
    switch (tipe) {
      case 'jadwal':
        return AppColors.imunisasiText;
      case 'rujukan':
        return AppColors.statusBurukText;
      case 'pengingat':
        return AppColors.vitaminAText;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconBgColor(String tipe) {
    switch (tipe) {
      case 'jadwal':
        return AppColors.imunisasiBg;
      case 'rujukan':
        return AppColors.statusBurukBg;
      case 'pengingat':
        return AppColors.vitaminABg;
      default:
        return AppColors.primarySurface;
    }
  }

  // ── Baca Semua ────────────────────────────────

  Future<void> _bacaSemua() async {
    await ref.read(notifikasiProvider.notifier).bacaSemuaNotifikasi();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua notifikasi ditandai sudah dibaca'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
