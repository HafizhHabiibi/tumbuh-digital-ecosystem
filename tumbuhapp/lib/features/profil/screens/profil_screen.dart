import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profil_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../router/app_router.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profil', style: AppTextStyles.heading3),
      ),
      body: profilAsync.when(
        loading: () => const ShimmerDetail(),
        error: (err, _) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(profilProvider),
        ),
        data: (profil) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Avatar ────────────────────
              _buildAvatar(profil.namaLengkap),
              const SizedBox(height: 24),

              // ── Data Profil ───────────────
              _buildSectionTitle('Data Profil'),
              const SizedBox(height: 12),
              _buildProfilCard(profil),
              const SizedBox(height: 24),

              // ── Akun ──────────────────────
              _buildSectionTitle('Akun'),
              const SizedBox(height: 12),
              _buildAkunCard(context, ref),
              const SizedBox(height: 24),

              // ── Versi App ─────────────────
              Text(
                'Versi ${AppConstants.appVersion}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────

  Widget _buildAvatar(String nama) {
    final inisial = nama.isNotEmpty
        ? nama.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              inisial,
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(nama, style: AppTextStyles.heading3),
      ],
    );
  }

  // ── Section Title ─────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  // ── Profil Card ───────────────────────────────

  Widget _buildProfilCard(profil) {
    final items = [
      _InfoItem(
        icon: Icons.person_outline,
        label: 'Nama Lengkap',
        value: profil.namaLengkap,
      ),
      _InfoItem(
        icon: Icons.email_outlined,
        label: 'Email',
        value: profil.userId,
      ),
      _InfoItem(
        icon: Icons.phone_outlined,
        label: 'No. HP',
        value: profil.noHp,
      ),
      _InfoItem(
        icon: Icons.location_on_outlined,
        label: 'Alamat',
        value: profil.alamat,
      ),
      _InfoItem(
        icon: Icons.badge_outlined,
        label: 'NIK',
        value: profil.nik,
      ),
    ];

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
                    Icon(item.icon, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label, style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(item.value, style: AppTextStyles.body),
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

  // ── Akun Card ─────────────────────────────────

  Widget _buildAkunCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Ubah Password
          ListTile(
            onTap: () => _showUbahPasswordSheet(context, ref),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            title: Text(
              'Ubah Password',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Logout
          ListTile(
            onTap: () => _showLogoutDialog(context, ref),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.statusBurukBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.statusBurukText,
                size: 18,
              ),
            ),
            title: Text(
              'Logout',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.statusBurukText,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Ubah Password Bottom Sheet ────────────────

  void _showUbahPasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UbahPasswordSheet(ref: ref),
    );
  }

  // ── Logout Dialog ─────────────────────────────

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Logout', style: AppTextStyles.heading3),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusBurukText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ubah Password Sheet ───────────────────────

class _UbahPasswordSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _UbahPasswordSheet({required this.ref});

  @override
  ConsumerState<_UbahPasswordSheet> createState() => _UbahPasswordSheetState();
}

class _UbahPasswordSheetState extends ConsumerState<_UbahPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final berhasil = await ref.read(ubahPasswordProvider.notifier).ubahPassword(
          passwordLama: _passwordLamaController.text,
          passwordBaru: _passwordBaruController.text,
        );

    if (berhasil && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ubahPasswordProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('Ubah Password', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(
                'Masukkan password lama dan password baru',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),

              // Password Lama
              _buildPasswordField(
                controller: _passwordLamaController,
                label: 'Password Lama',
                obscure: _obscureLama,
                onToggle: () => setState(() => _obscureLama = !_obscureLama),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password lama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Baru
              _buildPasswordField(
                controller: _passwordBaruController,
                label: 'Password Baru',
                obscure: _obscureBaru,
                onToggle: () => setState(() => _obscureBaru = !_obscureBaru),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password baru wajib diisi';
                  }
                  if (val.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Konfirmasi Password
              _buildPasswordField(
                controller: _konfirmasiController,
                label: 'Konfirmasi Password Baru',
                obscure: _obscureKonfirmasi,
                onToggle: () =>
                    setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (val != _passwordBaruController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Error
              if (state.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.statusBurukBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusBurukText),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.statusBurukText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.statusBurukText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Simpan Password',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.textSecondary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.statusBurukText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.statusBurukText, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

// ── Helper Class ──────────────────────────────

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
