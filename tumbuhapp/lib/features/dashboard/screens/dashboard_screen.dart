import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/anak_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifikasi/providers/notifikasi_provider.dart';
import '../../../shared/models/anak_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';
import '../../../router/app_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.child_care,
              color: AppColors.primary,
              size: 20,
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
              onPressed: () => context.push(AppRoutes.notifikasi),
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
        await ref.read(daftarAnakProvider.future);
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
              _buildCardAnak(context, selectedAnak),
              const SizedBox(height: 16),
            ],

            // ── Quick Menu ────────────────────
            _buildQuickMenuTitle(),
            const SizedBox(height: 12),
            _buildQuickMenu(context, selectedAnak),
            const SizedBox(height: 8),
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
          '$greeting, $firstName 👋',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Text(
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

  Widget _buildCardAnak(BuildContext context, AnakModel anak) {
    return GestureDetector(
      onTap: () => context.push('/anak/${anak.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama & usia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anak.nama,
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.hitungUsia(anak.tanggalLahir),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
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
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),

            // Info pengukuran terakhir
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white60,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap untuk lihat detail',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Menu ────────────────────────────────

  Widget _buildQuickMenuTitle() {
    return Text('Menu', style: AppTextStyles.heading3);
  }

  Widget _buildQuickMenu(BuildContext context, AnakModel? selectedAnak) {
    final anakId = selectedAnak?.id;

    void pushAnakRoute(String path) {
      if (anakId == null) return;
      context.push(path);
    }

    final menus = [
      _MenuItem(
        icon: Icons.monitor_weight_outlined,
        label: 'Pengukuran',
        color: AppColors.primary,
        bgColor: AppColors.primarySurface,
        onTap: () => pushAnakRoute('/anak/$anakId/pengukuran'),
      ),
      _MenuItem(
        icon: Icons.show_chart,
        label: 'Grafik',
        color: const Color(0xFF1D4ED8),
        bgColor: const Color(0xFFDBEAFE),
        onTap: () => pushAnakRoute('/anak/$anakId/grafik'),
      ),
      _MenuItem(
        icon: Icons.vaccines_outlined,
        label: 'Pemberian',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        onTap: () => pushAnakRoute('/anak/$anakId/pemberian'),
      ),
      _MenuItem(
        icon: Icons.local_hospital_outlined,
        label: 'Rujukan',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        onTap: () => pushAnakRoute('/anak/$anakId/rujukan'),
      ),
      _MenuItem(
        icon: Icons.calendar_month_outlined,
        label: 'Jadwal',
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
        onTap: () => context.push(AppRoutes.jadwal),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEE2E2),
        onTap: () => context.push(AppRoutes.notifikasi),
      ),
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Profil',
        color: const Color(0xFF6B7280),
        bgColor: const Color(0xFFF3F4F6),
        onTap: () => context.push(AppRoutes.profil),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: menus.length,
      itemBuilder: (_, index) => _buildMenuItem(menus[index]),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Menu Item Model ───────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
