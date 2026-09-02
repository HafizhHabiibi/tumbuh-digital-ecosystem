import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Tumbuh';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';

  // Timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int chatReceiveTimeout = 60000;
}

class AppColors {
  AppColors._();

  // Primary App
  static const Color primary = Color(0xFF008F24);
  static const Color primaryDark = Color(0xFF006E1C);
  static const Color primarySurface =
      Color(0xFFE8F5E9); // Soft light green for accents

  // ── Status Gizi ──────────────────────────────
  static const Color statusNormalText = Color(0xFF15803D);
  static const Color statusNormalBg = Color(0xFFDCFCE7);

  static const Color statusKurangText = Color(0xFFD97706);
  static const Color statusKurangBg = Color(0xFFFEF3C7);

  static const Color statusBurukText = Color(0xFFDC2626);
  static const Color statusBurukBg = Color(0xFFFEE2E2);

  static const Color statusLebihText = Color(0xFF2563EB);
  static const Color statusLebihBg = Color(0xFFDBEAFE);

  // ── Risiko Stunting ───────────────────────────
  static const Color risikoRendahText = Color(0xFF15803D);
  static const Color risikoRendahBg = Color(0xFFDCFCE7);

  // ...
  static const Color risikoSedangText = Color(0xFF1D4ED8);
  static const Color risikoSedangBg = Color(0xFFDBEAFE);

  static const Color risikoTinggiText = Color(0xFFDC2626);
  static const Color risikoTinggiBg = Color(0xFFFEE2E2);

  // ── Status Rujukan ────────────────────────────
  static const Color rujukanDiajukanText = Color(0xFF2563EB);
  static const Color rujukanDiajukanBg = Color(0xFFDBEAFE);

  static const Color rujukanDiterimaText = Color(0xFF15803D);
  static const Color rujukanDiterimaBg = Color(0xFFDCFCE7);

  static const Color rujukanPenangananText = Color(0xFFD97706);
  static const Color rujukanPenangananBg = Color(0xFFFEF3C7);

  static const Color rujukanSelesaiText = Color(0xFF6B7280);
  static const Color rujukanSelesaiBg = Color(0xFFF3F4F6);

  static const Color rujukanDitolakText = Color(0xFFDC2626);
  static const Color rujukanDitolakBg = Color(0xFFFEE2E2);

  // ── Jenis Kelamin ─────────────────────────────
  static const Color lakiLakiText = Color(0xFF1D4ED8);
  static const Color lakiLakiBg = Color(0xFFDBEAFE);

  static const Color perempuanText = Color(0xFFBE185D);
  static const Color perempuanBg = Color(0xFFFCE7F3);

  // ── Jenis Pemberian ───────────────────────────
  static const Color imunisasiText = Color(0xFF1D4ED8);
  static const Color imunisasiBg = Color(0xFFDBEAFE);

  static const Color vitaminAText = Color(0xFFD97706);
  static const Color vitaminABg = Color(0xFFFEF3C7);

  static const Color obatCacingText = Color(0xFF15803D);
  static const Color obatCacingBg = Color(0xFFDCFCE7);

  static const Color pmtText = Color(0xFF7C3AED);
  static const Color pmtBg = Color(0xFFEDE9FE);

  // ── Neutral ───────────────────────────────────
  static const Color background = Color(0xFFFAFAFA); // White base background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF475569); // Medium slate
  static const Color textMuted = Color(0xFF94A3B8); // Light slate
  static const Color border = Color(0xFFE2E8F0); // Very light slate/grey
  static const Color divider = Color(0xFFF1F5F9); // Clean slate divider
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
