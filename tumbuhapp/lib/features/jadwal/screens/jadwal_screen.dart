import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jadwal_provider.dart';
import '../../../shared/models/jadwal_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';

class JadwalScreen extends ConsumerStatefulWidget {
  const JadwalScreen({super.key});

  @override
  ConsumerState<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends ConsumerState<JadwalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jadwalProvider.notifier).fetchJadwal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jadwalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Jadwal Posyandu', style: AppTextStyles.heading3),
      ),
      body: _buildContent(state),
    );
  }

  // ── Content ───────────────────────────────────

  Widget _buildContent(JadwalState state) {
    if (state.isLoading) {
      return const ShimmerList(itemCount: 4, itemHeight: 120);
    }

    if (state.errorMessage != null) {
      return ErrorStateWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(jadwalProvider.notifier).fetchJadwal(),
      );
    }

    final jadwalMendatang = state.jadwalMendatang;
    final jadwalTerlewat = state.jadwalTerlewat;

    if (jadwalMendatang.isEmpty && jadwalTerlewat.isEmpty) {
      return const EmptyJadwal();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(jadwalProvider.notifier).fetchJadwal(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (jadwalMendatang.isNotEmpty) ...[
            _buildSectionHeader(
              title: 'Jadwal Mendatang',
              subtitle: 'Jadwal hari ini dan yang akan datang',
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < jadwalMendatang.length; index++) ...[
              _buildJadwalCard(
                jadwalMendatang[index],
                state.jadwalBulanIni.contains(jadwalMendatang[index]),
              ),
              if (index < jadwalMendatang.length - 1)
                const SizedBox(height: 12),
            ],
          ] else
            _buildTidakAdaJadwalMendatang(),
          if (jadwalTerlewat.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(
              title: 'Riwayat Jadwal',
              subtitle: 'Jadwal Posyandu yang sudah terlewat',
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < jadwalTerlewat.length; index++) ...[
              _buildJadwalCard(
                jadwalTerlewat[index],
                false,
                isTerlewat: true,
              ),
              if (index < jadwalTerlewat.length - 1) const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTidakAdaJadwalMendatang() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada jadwal Posyandu mendatang.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  // ── Jadwal Card ───────────────────────────────

  Widget _buildJadwalCard(
    JadwalModel jadwal,
    bool isBulanIni, {
    bool isTerlewat = false,
  }) {
    final tanggal = _parseTanggal(jadwal.tanggal);
    final isHariIni = tanggal != null && _isHariIni(tanggal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBulanIni ? AppColors.primary : AppColors.border,
          width: isBulanIni ? 2 : 1,
        ),
        boxShadow: isBulanIni
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
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
          _buildCardHeader(
            jadwal,
            tanggal,
            isBulanIni,
            isHariIni,
            isTerlewat,
          ),

          // ── Detail ────────────────────────
          _buildCardDetail(jadwal),
        ],
      ),
    );
  }

  // ── Card Header ───────────────────────────────

  Widget _buildCardHeader(
    JadwalModel jadwal,
    DateTime? tanggal,
    bool isBulanIni,
    bool isHariIni,
    bool isTerlewat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBulanIni ? AppColors.primarySurface : AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Tanggal box
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isBulanIni ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tanggal != null ? '${tanggal.day}' : '-',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  tanggal != null ? _getNamaBulanSingkat(tanggal.month) : '-',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Info tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tanggal != null
                            ? FormatUtils.formatTanggalLengkap(jadwal.tanggal)
                            : '-',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isBulanIni
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatWaktu(jadwal.waktuMulai)} - ${_formatWaktu(jadwal.waktuSelesai)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status jadwal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isTerlewat)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Terlewat',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!isTerlewat && isHariIni)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Hari Ini',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!isTerlewat && isHariIni && isBulanIni)
                const SizedBox(height: 4),
              if (!isTerlewat && isBulanIni)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Text(
                    'Bulan Ini',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card Detail ───────────────────────────────

  Widget _buildCardDetail(JadwalModel jadwal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),

          // Lokasi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lokasi', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(jadwal.lokasi, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),

          // Keterangan
          if (jadwal.keterangan != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Keterangan', style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        jadwal.keterangan!,
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Dibuat oleh
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Dibuat oleh ${jadwal.dibuatOleh}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────

  DateTime? _parseTanggal(String tanggal) {
    try {
      return DateTime.parse(tanggal);
    } catch (_) {
      return null;
    }
  }

  bool _isHariIni(DateTime tanggal) {
    final now = DateTime.now();
    return tanggal.year == now.year &&
        tanggal.month == now.month &&
        tanggal.day == now.day;
  }

  String _formatWaktu(String waktu) {
    // "08:00:00" → "08:00"
    try {
      return waktu.substring(0, 5);
    } catch (_) {
      return waktu;
    }
  }

  String _getNamaBulanSingkat(int bulan) {
    const list = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return list[bulan - 1];
  }
}
