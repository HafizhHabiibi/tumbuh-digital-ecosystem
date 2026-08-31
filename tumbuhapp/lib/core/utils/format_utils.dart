import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  // ── Format Tanggal ────────────────────────────

  // 2024-03-15 → 15 Maret 2024
  static String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal).toLocal();
      return DateFormat('d MMMM yyyy', 'id').format(date);
    } catch (_) {
      return '-';
    }
  }

  // 2024-03-15 → Jumat, 15 Maret 2024
  static String formatTanggalLengkap(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal).toLocal();
      return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
    } catch (_) {
      return '-';
    }
  }

  // 2024-03-15T10:30:00 → 10:30
  static String formatJam(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal).toLocal();
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return '-';
    }
  }

  // 2024-03-15T10:30:00 → 15 Maret 2024, 10:30
  static String formatTanggalJam(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal).toLocal();
      return DateFormat('d MMMM yyyy, HH:mm', 'id').format(date);
    } catch (_) {
      return '-';
    }
  }

  // ── Waktu Relatif ─────────────────────────────
  // Untuk notifikasi: "2 jam lalu", "kemarin", dll

  static String formatWaktuRelatif(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return formatTanggal(tanggal);
    } catch (_) {
      return '-';
    }
  }

  // ── Format Angka ──────────────────────────────

  // 72.5 → "72,5 KG"
  static String formatBeratBadan(double? nilai) {
    if (nilai == null) return '-';
    final formatted = nilai % 1 == 0
        ? nilai.toInt().toString()
        : nilai.toStringAsFixed(1).replaceAll('.', ',');
    return '$formatted KG';
  }

  // 85.3 → "85,3 CM"
  static String formatTinggiBadan(double? nilai) {
    if (nilai == null) return '-';
    final formatted = nilai % 1 == 0
        ? nilai.toInt().toString()
        : nilai.toStringAsFixed(1).replaceAll('.', ',');
    return '$formatted CM';
  }

  // ── Usia ──────────────────────────────────────────────

  // "2006-05-15" → "8 bulan" | "1 tahun 3 bulan" | "2 tahun"
  // Ambang batas: < 12 bulan → "X bulan", >= 12 bulan → "X tahun Y bulan"
  static String hitungUsia(String? tanggalLahir) {
    if (tanggalLahir == null || tanggalLahir.isEmpty) return '-';
    try {
      final lahir = DateTime.parse(tanggalLahir);
      final now = DateTime.now();

      int tahun = now.year - lahir.year;
      int bulan = now.month - lahir.month;

      // Koreksi hari: jika hari ini belum sampai hari lahir di bulan ini
      if (now.day < lahir.day) {
        bulan--;
      }

      if (bulan < 0) {
        tahun--;
        bulan += 12;
      }

      final totalBulan = tahun * 12 + bulan;
      if (totalBulan < 12) return '$totalBulan bulan';
      if (bulan == 0) return '$tahun tahun';
      return '$tahun tahun $bulan bulan';
    } catch (_) {
      return '-';
    }
  }

  // "2006-05-15" → 38 (dalam bulan, untuk grafik WHO)
  static int? hitungUsiaBulan(String? tanggalLahir) {
    if (tanggalLahir == null || tanggalLahir.isEmpty) return null;
    try {
      final lahir = DateTime.parse(tanggalLahir);
      final now = DateTime.now();
      return (now.year - lahir.year) * 12 + (now.month - lahir.month);
    } catch (_) {
      return null;
    }
  }
}
