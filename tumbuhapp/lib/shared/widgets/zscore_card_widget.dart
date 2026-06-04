import 'package:flutter/material.dart';
import '../../core/constant/app_constants.dart';
import '../../core/utils/format_utils.dart';

enum ZScoreType { bbu, tbu, bbtb }

class ZScoreCard extends StatelessWidget {
  final ZScoreType type;
  final double nilai;

  const ZScoreCard({
    super.key,
    required this.type,
    required this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    final colors = _getColors(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.$1.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tipe Z-Score ──────────────────
          Text(
            _getLabel(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // ── Nilai ─────────────────────────
          Text(
            FormatUtils.formatZScore(nilai),
            style: AppTextStyles.heading3.copyWith(
              color: colors.$1,
            ),
          ),
          const SizedBox(height: 6),

          // ── Status Badge ──────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.$1.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusLabel(status),
              style: AppTextStyles.caption.copyWith(
                color: colors.$1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Indikator Bar ─────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _getNormalizedValue(),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.$1),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Label per Tipe ────────────────────────────

  String _getLabel() {
    switch (type) {
      case ZScoreType.bbu:
        return 'BB/U';
      case ZScoreType.tbu:
        return 'TB/U';
      case ZScoreType.bbtb:
        return 'BB/TB';
    }
  }

  // ── Status berdasarkan nilai Z-Score ──────────

  String _getStatus() {
    switch (type) {
      case ZScoreType.bbu:
        return _statusBbu();
      case ZScoreType.tbu:
        return _statusTbu();
      case ZScoreType.bbtb:
        return _statusBbtb();
    }
  }

  String _statusBbu() {
    if (nilai < -3) return 'buruk';
    if (nilai < -2) return 'kurang';
    if (nilai <= 2) return 'normal';
    return 'lebih';
  }

  String _statusTbu() {
    if (nilai < -3) return 'sangat_pendek';
    if (nilai < -2) return 'pendek';
    if (nilai <= 2) return 'normal';
    return 'tinggi';
  }

  String _statusBbtb() {
    if (nilai < -3) return 'buruk';
    if (nilai < -2) return 'kurang';
    if (nilai <= 2) return 'normal';
    if (nilai <= 3) return 'lebih';
    return 'obesitas';
  }

  // ── Status Label ──────────────────────────────

  String _getStatusLabel(String status) {
    switch (status) {
      case 'buruk':
        return 'Gizi Buruk';
      case 'kurang':
        return 'Gizi Kurang';
      case 'normal':
        return 'Normal';
      case 'lebih':
        return 'Gizi Lebih';
      case 'obesitas':
        return 'Obesitas';
      case 'sangat_pendek':
        return 'Sangat Pendek';
      case 'pendek':
        return 'Pendek (Stunting)';
      case 'tinggi':
        return 'Tinggi';
      default:
        return status;
    }
  }

  // ── Colors berdasarkan Status ─────────────────

  (Color, Color) _getColors(String status) {
    switch (status) {
      case 'normal':
      case 'tinggi':
        return (AppColors.statusNormalText, AppColors.statusNormalBg);
      case 'kurang':
      case 'pendek':
        return (AppColors.statusKurangText, AppColors.statusKurangBg);
      case 'buruk':
      case 'sangat_pendek':
        return (AppColors.statusBurukText, AppColors.statusBurukBg);
      case 'lebih':
      case 'obesitas':
        return (AppColors.statusLebihText, AppColors.statusLebihBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }

  // ── Normalized Value untuk Progress Bar ───────
  // Z-Score range -5 sampai +5, dinormalisasi ke 0.0 - 1.0

  double _getNormalizedValue() {
    const min = -5.0;
    const max = 5.0;
    final clamped = nilai.clamp(min, max);
    return (clamped - min) / (max - min);
  }
}

// ── Z-Score Row ───────────────────────────────
// Wrapper 3 kartu sejajar untuk detail pengukuran

class ZScoreRow extends StatelessWidget {
  final double zscoreBbu;
  final double zscoreTbu;
  final double zscoreBbtb;

  const ZScoreRow({
    super.key,
    required this.zscoreBbu,
    required this.zscoreTbu,
    required this.zscoreBbtb,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ZScoreCard(type: ZScoreType.bbu, nilai: zscoreBbu),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ZScoreCard(type: ZScoreType.tbu, nilai: zscoreTbu),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ZScoreCard(type: ZScoreType.bbtb, nilai: zscoreBbtb),
        ),
      ],
    );
  }
}
