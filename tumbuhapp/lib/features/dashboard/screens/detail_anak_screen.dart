import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../laporan/data/laporan_service.dart';
import '../../laporan/providers/laporan_provider.dart';

class DetailAnakScreen extends ConsumerStatefulWidget {
  final String anakId;

  const DetailAnakScreen({super.key, required this.anakId});

  @override
  ConsumerState<DetailAnakScreen> createState() => _DetailAnakScreenState();
}

class _DetailAnakScreenState extends ConsumerState<DetailAnakScreen> {
  bool _isDownloading = false;

  String get anakId => widget.anakId;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(detailAnakProvider(anakId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const SafeArea(child: ShimmerDetail()),
        error: (err, _) => SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () => ref.refresh(detailAnakProvider(anakId)),
                ),
              ),
            ],
          ),
        ),
        data: (anak) => CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar inisial
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Center(
                                  child: Text(
                                    anak.nama.isNotEmpty
                                        ? anak.nama[0].toUpperCase()
                                        : '?',
                                    style: AppTextStyles.heading1.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      anak.nama,
                                      style: AppTextStyles.heading2.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          FormatUtils.hitungUsia(
                                              anak.tanggalLahir),
                                          style: AppTextStyles.body.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        StatusBadge(
                                          label: anak.jenisKelamin,
                                          type: StatusType.jenisKelamin,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info Dasar ──────────
                    _buildSectionTitle('Informasi Dasar'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoItem(
                        icon: Icons.cake_outlined,
                        label: 'Tanggal Lahir',
                        value: FormatUtils.formatTanggal(anak.tanggalLahir),
                      ),
                      _InfoItem(
                        icon: Icons.badge_outlined,
                        label: 'NIK',
                        value: anak.nik,
                      ),
                      _InfoItem(
                        icon: Icons.person_outline,
                        label: 'Orang Tua',
                        value: anak.namaOrangTua ?? '-',
                      ),
                      _InfoItem(
                        icon: Icons.phone_outlined,
                        label: 'No. HP',
                        value: anak.noHpOrangTua ?? '-',
                      ),
                      _InfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat',
                        value: anak.alamatOrangTua ?? '-',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── Menu Fitur ──────────
                    _buildSectionTitle('Fitur'),
                    const SizedBox(height: 12),
                    _buildFiturMenu(context, anak.nama),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  // ── Info Card ─────────────────────────────────

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Fitur Menu ────────────────────────────────

  Widget _buildFiturMenu(BuildContext context, String namaAnak) {
    final menus = [
      _FiturItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Riwayat Pengukuran',
        subtitle: 'Lihat pertumbuhan dan status gizi anak',
        color: AppColors.primary,
        bgColor: AppColors.primarySurface,
        onTap: () => context.push('/anak/$anakId/pengukuran'),
      ),
      _FiturItem(
        icon: Icons.show_chart,
        label: 'Grafik Pertumbuhan',
        subtitle: 'Visualisasi pertumbuhan vs WHO',
        color: const Color(0xFF1D4ED8),
        bgColor: const Color(0xFFDBEAFE),
        onTap: () => context.push('/anak/$anakId/grafik'),
      ),
      _FiturItem(
        icon: Icons.vaccines_outlined,
        label: 'Riwayat Pemberian',
        subtitle: 'Imunisasi, vitamin, dan obat',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        onTap: () => context.push('/anak/$anakId/pemberian'),
      ),
      _FiturItem(
        icon: Icons.local_hospital_outlined,
        label: 'Status Rujukan',
        subtitle: 'Pantau status rujukan anak',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        onTap: () => context.push('/anak/$anakId/rujukan'),
      ),
      _FiturItem(
        icon: Icons.picture_as_pdf_outlined,
        label: 'Unduh Laporan',
        subtitle: 'Simpan ringkasan pertumbuhan dalam PDF',
        color: const Color(0xFFB91C1C),
        bgColor: const Color(0xFFFEE2E2),
        isLoading: _isDownloading,
        onTap: _isDownloading ? null : () => _downloadLaporan(namaAnak),
      ),
    ];

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: menus.asMap().entries.map((entry) {
          final index = entry.key;
          final menu = entry.value;
          final isLast = index == menus.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: menu.onTap,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: menu.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(menu.icon, color: menu.color, size: 20),
                ),
                title: Text(menu.label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                subtitle: Text(menu.subtitle, style: AppTextStyles.caption),
                trailing: menu.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _downloadLaporan(String namaAnak) async {
    setState(() => _isDownloading = true);
    try {
      final result =
          await ref.read(laporanServiceProvider).downloadLaporanAnak(anakId);
      if (!mounted) return;
      _showMessage(
        'Laporan $namaAnak berhasil disimpan sebagai ${result.fileName}',
        AppColors.primary,
      );
    } on LaporanDownloadCancelled {
      if (mounted) {
        _showMessage('Penyimpanan laporan dibatalkan', AppColors.textSecondary);
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          ErrorUtils.getCleanErrorMessage(error),
          AppColors.statusBurukText,
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }
}

// ── Helper Classes ────────────────────────────

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _FiturItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const _FiturItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.isLoading = false,
  });
}
