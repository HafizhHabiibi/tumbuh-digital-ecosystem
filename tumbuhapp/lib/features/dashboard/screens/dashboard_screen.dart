import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifikasi/providers/notifikasi_provider.dart';
import '../../pengukuran/providers/pengukuran_provider.dart';
import '../../../shared/models/anak_model.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../shared/widgets/insight_card_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/services/fcm_service.dart';
import '../../../router/app_router.dart';
import '../../conversational_ai/widgets/chat_entry_card.dart';
import '../../laporan/data/laporan_service.dart';
import '../../laporan/providers/laporan_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    // Auto select anak pertama
    ref.watch(autoSelectAnakProvider);

    final authState = ref.watch(authProvider);
    final daftarAnakAsync = ref.watch(daftarAnakProvider);
    final selectedAnak = ref.watch(selectedAnakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, authState),
      body: daftarAnakAsync.when(
        loading: () => const ShimmerDashboard(),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(daftarAnakProvider),
        ),
        data: (daftarAnak) {
          if (daftarAnak.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.child_care,
              title: 'Belum Ada Data Anak',
              message:
                  'Data anak Anda belum terdaftar.\nSilakan hubungi kader posyandu.',
            );
          }
          return _buildBody(context, ref, daftarAnak, selectedAnak);
        },
      ),
    );
  }

  // ── App Bar ───────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final belumDibacaAsync = ref.watch(belumDibacaProvider);
    final badgeCount = belumDibacaAsync.maybeWhen(
      data: (val) => val,
      orElse: () => 0,
    );

    // Assign callback FCM agar badge naik otomatis saat notif foreground masuk
    FcmService.onNewMessage = () => ref.invalidate(belumDibacaProvider);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/icon/tumbuh.png',
              width: 36,
              height: 36,
              color: AppColors.primary,
              colorBlendMode: BlendMode.srcIn,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        // Notifikasi dengan badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () async {
                await context.push(AppRoutes.notifikasi);
                // Refresh badge setelah kembali dari halaman notifikasi
                ref.invalidate(belumDibacaProvider);
              },
            ),
            if (badgeCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.statusBurukText,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Body ──────────────────────────────────────

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<AnakModel> daftarAnak,
    AnakModel? selectedAnak,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(daftarAnakProvider);
        if (selectedAnak != null) {
          ref.invalidate(pengukuranTerakhirProvider(selectedAnak.id));
        }

        await ref.read(daftarAnakProvider.future);
        if (selectedAnak != null) {
          await ref.read(
            pengukuranTerakhirProvider(selectedAnak.id).future,
          );
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sapaan ────────────────────────
            _buildSapaan(ref),
            const SizedBox(height: 20),

            // ── Selector Anak (kalau > 1) ─────
            if (daftarAnak.length > 1) ...[
              _buildAnakSelector(ref, daftarAnak),
              const SizedBox(height: 16),
            ],

            // ── Card Ringkasan Anak ───────────
            if (selectedAnak != null) ...[
              _buildCardAnak(context, ref, selectedAnak),
              const SizedBox(height: 20),
            ],

            // ── Quick Menu ────────────────────
            _buildQuickMenuTitle(),
            const SizedBox(height: 12),
            _buildQuickMenu(context, ref, selectedAnak),
            const SizedBox(height: 24),

            // ── AI Insight ────────────────────
            _buildInsightSection(context, ref, selectedAnak),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Sapaan ────────────────────────────────────

  Widget _buildSapaan(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final nama = authState.user?.namaLengkap ?? '';
    final firstName = nama.split(' ').first;
    final hour = DateTime.now().hour;

    String greeting;
    if (hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $firstName',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        const Text(
          'Pantau tumbuh kembang si kecil hari ini',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  // ── Anak Selector ─────────────────────────────

  Widget _buildAnakSelector(WidgetRef ref, List<AnakModel> daftarAnak) {
    final selectedIndex = ref.watch(selectedAnakIndexProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: daftarAnak.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final anak = daftarAnak[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              ref.invalidate(pengukuranTerakhirProvider(anak.id));
              ref.read(selectedAnakIndexProvider.notifier).state = index;
              ref.read(selectedAnakProvider.notifier).state = anak;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                anak.nama,
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Card Ringkasan Anak ───────────────────────

  Widget _buildCardAnak(BuildContext context, WidgetRef ref, AnakModel anak) {
    final terakhirAsync = ref.watch(pengukuranTerakhirProvider(anak.id));

    return terakhirAsync.when(
      loading: () => Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildCardAnakBase(context, anak, null),
      data: (terakhir) => _buildCardAnakBase(context, anak, terakhir),
    );
  }

  Widget _buildCardAnakBase(
      BuildContext context, AnakModel anak, PengukuranModel? terakhir) {
    return GestureDetector(
      onTap: () => context.push('/anak/${anak.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF00B02D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Nama, Gender, Usia
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anak.nama,
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.hitungUsia(anak.tanggalLahir),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: anak.jenisKelamin,
                  type: StatusType.jenisKelamin,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // Row 2: Pengukuran Terakhir (jika ada)
            if (terakhir != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pengukuran terakhir: ${FormatUtils.formatTanggal(terakhir.tanggalUkur)}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Berat Badan',
                      FormatUtils.formatBeratBadan(terakhir.beratBadan)),
                  _buildMiniStat('Tinggi Badan',
                      FormatUtils.formatTinggiBadan(terakhir.tinggiBadan)),
                  _buildMiniStat(
                    'Status Gizi',
                    formatStatusAntropometri(terakhir.statusBbtb),
                    isBadge: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
            ] else ...[
              Text(
                'Belum ada riwayat pengukuran anak.',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Row 3: Info Tap
            Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap untuk lihat detail perkembangan anak',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isBadge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  // ── Quick Menu ────────────────────────────────

  Widget _buildQuickMenuTitle() {
    return const Text('Menu Layanan', style: AppTextStyles.heading3);
  }

  Widget _buildQuickMenu(
      BuildContext context, WidgetRef ref, AnakModel? selectedAnak) {
    final anakId = selectedAnak?.id;

    void pushAnakRoute(String path) {
      if (anakId == null) return;
      context.push(path);
    }

    final menus = [
      _MenuItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Riwayat Pengukuran',
        subtitle: 'Input berat, tinggi & lingkar lengan',
        color: AppColors.primary,
        bgColor: AppColors.primarySurface,
        onTap: () => pushAnakRoute('/anak/$anakId/pengukuran'),
      ),
      _MenuItem(
        icon: Icons.show_chart,
        label: 'Grafik Pertumbuhan',
        subtitle: 'Pantau kurva pertumbuhan',
        color: const Color(0xFF1D4ED8),
        bgColor: const Color(0xFFDBEAFE),
        onTap: () => pushAnakRoute('/anak/$anakId/grafik'),
      ),
      _MenuItem(
        icon: Icons.vaccines_outlined,
        label: 'Riwayat Pemberian',
        subtitle: 'Imunisasi, Vitamin A & PMT',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        onTap: () => pushAnakRoute('/anak/$anakId/pemberian'),
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        label: 'Jadwal Posyandu',
        subtitle: 'Jadwal penimbangan terdekat',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
        onTap: () => context.push(AppRoutes.jadwal),
      ),
      _MenuItem(
        icon: Icons.local_hospital_outlined,
        label: 'Status Rujukan',
        subtitle: 'Ajukan rujukan ke Puskesmas',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        onTap: () => pushAnakRoute('/anak/$anakId/rujukan'),
      ),
      _MenuItem(
        icon: Icons.picture_as_pdf_outlined,
        label: 'Unduh Laporan',
        subtitle: 'Simpan ringkasan pertumbuhan',
        color: const Color(0xFFB91C1C),
        bgColor: const Color(0xFFFEE2E2),
        isLoading: _isDownloading,
        onTap: _isDownloading || selectedAnak == null
            ? null
            : () => _downloadLaporan(selectedAnak),
      ),
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Profil & Akun',
        subtitle: 'Informasi data diri & keluarga',
        color: const Color(0xFF6B7280),
        bgColor: const Color(0xFFF3F4F6),
        onTap: () => context.push(AppRoutes.profil),
      ),
    ];

    final featuredMenu = menus.first;
    final gridMenus = menus.sublist(1);

    return Column(
      children: [
        // Featured full-width card for Pengukuran
        _HoverableMenuItemCard(item: featuredMenu, isFullWidth: true),
        const SizedBox(height: 12),
        // Grid for remaining menus
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemCount: gridMenus.length,
          itemBuilder: (_, index) =>
              _HoverableMenuItemCard(item: gridMenus[index]),
        ),
      ],
    );
  }

  Future<void> _downloadLaporan(AnakModel anak) async {
    setState(() => _isDownloading = true);
    try {
      final result =
          await ref.read(laporanServiceProvider).downloadLaporanAnak(anak.id);
      if (!mounted) return;
      _showMessage(
        'Laporan ${anak.nama} berhasil disimpan sebagai ${result.fileName}',
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

  // ── AI Insight Section ────────────────────────

  Widget _buildInsightSection(
      BuildContext context, WidgetRef ref, AnakModel? selectedAnak) {
    if (selectedAnak == null) return const SizedBox.shrink();

    final terakhirAsync =
        ref.watch(pengukuranTerakhirProvider(selectedAnak.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Insight Perkembangan',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        terakhirAsync.when(
          loading: () => const InsightCard(isLoading: true),
          error: (err, _) => const InsightCard(),
          data: (terakhir) {
            if (terakhir == null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI Insight Belum Tersedia',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Silakan input data pengukuran pertama untuk melihat analisis tumbuh kembang berbasis AI.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/anak/${selectedAnak.id}/pengukuran');
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Input Pengukuran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Jika ada pengukuran terakhir, fetch insight-nya
            final insightState = ref.watch(insightProvider(terakhir.id));

            return Column(
              children: [
                InsightCard(
                  insightTeks: insightState.insight?.insightTeks,
                  createdAt: insightState.insight?.insightGeneratedAt,
                  status: insightState.insight?.status,
                  isLoading: insightState.isLoading || insightState.isPolling,
                  pollingTimedOut: insightState.pollingTimedOut,
                  errorMessage: insightState.errorMessage,
                  onRefresh: () =>
                      ref.read(insightProvider(terakhir.id).notifier).refresh(),
                ),
                const SizedBox(height: 12),
                ChatEntryCard(
                  insightStatus: insightState.insight?.status,
                  onPressed: () => context.push(
                    AppRoutes.chatPengukuranLocation(
                      terakhir.id,
                      tanggalPengukuran: terakhir.tanggalUkur,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Hoverable Menu Item Card Widget ────────────

class _HoverableMenuItemCard extends StatefulWidget {
  final _MenuItem item;
  final bool isFullWidth;

  const _HoverableMenuItemCard({
    required this.item,
    this.isFullWidth = false,
  });

  @override
  State<_HoverableMenuItemCard> createState() => _HoverableMenuItemCardState();
}

class _HoverableMenuItemCardState extends State<_HoverableMenuItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isFullWidth = widget.isFullWidth;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: item.color.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()..translateByDouble(0, -6, 0, 1))
              : Matrix4.identity(),
          padding: EdgeInsets.all(widget.isFullWidth ? 16 : 14),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? item.color.withValues(alpha: 0.5)
                  : AppColors.border,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: item.color.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: isFullWidth
              ? Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: item.isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                color: item.color,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              item.icon,
                              color: item.color,
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.label,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _isHovered ? item.color : AppColors.textMuted,
                      size: 16,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: item.isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                color: item.color,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              item.icon,
                              color: item.color,
                              size: 20,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Menu Item Model ───────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.isLoading = false,
  });
}
