import 'package:flutter/material.dart';
import '../../core/constant/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ──────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────
            Text(
              title,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ── Message ───────────────────────
            Text(
              message,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),

            // ── Action Button ─────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Preset Empty States ───────────────────────
// Shortcut untuk empty state yang sering dipakai

class EmptyPengukuran extends StatelessWidget {
  const EmptyPengukuran({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.monitor_weight_outlined,
      title: 'Belum Ada Pengukuran',
      message:
          'Data pengukuran anak akan muncul\nsetelah kader melakukan pengukuran.',
    );
  }
}

class EmptyPemberian extends StatelessWidget {
  const EmptyPemberian({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.vaccines_outlined,
      title: 'Belum Ada Pemberian',
      message:
          'Riwayat pemberian imunisasi, vitamin,\ndan obat akan muncul di sini.',
    );
  }
}

class EmptyRujukan extends StatelessWidget {
  const EmptyRujukan({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.local_hospital_outlined,
      title: 'Tidak Ada Rujukan',
      message: 'Anak Anda belum memiliki\nriwayat rujukan saat ini.',
    );
  }
}

class EmptyNotifikasi extends StatelessWidget {
  const EmptyNotifikasi({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'Tidak Ada Notifikasi',
      message:
          'Notifikasi jadwal, pengukuran, dan\nrujukan akan muncul di sini.',
    );
  }
}

class EmptyJadwal extends StatelessWidget {
  const EmptyJadwal({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.calendar_month_outlined,
      title: 'Belum Ada Jadwal',
      message: 'Jadwal posyandu mendatang\nakan muncul di sini.',
    );
  }
}

class EmptyGrafik extends StatelessWidget {
  const EmptyGrafik({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.show_chart_outlined,
      title: 'Belum Ada Data Grafik',
      message:
          'Grafik pertumbuhan akan tampil\nsetelah ada minimal 1 pengukuran.',
    );
  }
}

// ── Error State ───────────────────────────────

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Gagal Memuat Data',
      message: message,
      actionLabel: 'Coba Lagi',
      onAction: onRetry,
    );
  }
}
