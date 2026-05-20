import 'package:flutter/material.dart';
import '../../core/constant/app_constants.dart';

enum StatusType {
  statusGizi,
  kategoriRisiko,
  statusRujukan,
  jenisKelamin,
  jenisPemberian,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(),
        style: AppTextStyles.label.copyWith(
          color: colors.$1,
          fontSize: 11,
        ),
      ),
    );
  }

  // ── Label ─────────────────────────────────────

  String _getLabel() {
    switch (type) {
      case StatusType.statusGizi:
        return _labelStatusGizi();
      case StatusType.kategoriRisiko:
        return _labelKategoriRisiko();
      case StatusType.statusRujukan:
        return _labelStatusRujukan();
      case StatusType.jenisKelamin:
        return label == 'L' ? 'Laki-laki' : 'Perempuan';
      case StatusType.jenisPemberian:
        return _labelJenisPemberian();
    }
  }

  String _labelStatusGizi() {
    switch (label.toLowerCase()) {
      case 'normal':
        return 'Normal';
      case 'kurang':
        return 'Kurang';
      case 'buruk':
        return 'Buruk';
      case 'lebih':
        return 'Lebih';
      default:
        return label;
    }
  }

  String _labelKategoriRisiko() {
    switch (label.toLowerCase()) {
      case 'rendah':
        return 'Risiko Rendah';
      case 'sedang':
        return 'Risiko Sedang';
      case 'tinggi':
        return 'Risiko Tinggi';
      default:
        return label;
    }
  }

  String _labelStatusRujukan() {
    switch (label.toLowerCase()) {
      case 'diajukan':
        return 'Diajukan';
      case 'diterima':
        return 'Diterima';
      case 'dalam_penanganan':
        return 'Dalam Penanganan';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return label;
    }
  }

  String _labelJenisPemberian() {
    switch (label.toLowerCase()) {
      case 'imunisasi':
        return 'Imunisasi';
      case 'vitamin_a':
        return 'Vitamin A';
      case 'obat_cacing':
        return 'Obat Cacing';
      case 'pmt':
        return 'PMT';
      default:
        return label;
    }
  }

  // ── Colors ────────────────────────────────────

  (Color, Color) _getColors() {
    switch (type) {
      case StatusType.statusGizi:
        return _colorsStatusGizi();
      case StatusType.kategoriRisiko:
        return _colorsKategoriRisiko();
      case StatusType.statusRujukan:
        return _colorsStatusRujukan();
      case StatusType.jenisKelamin:
        return label == 'L'
            ? (AppColors.lakiLakiText, AppColors.lakiLakiBg)
            : (AppColors.perempuanText, AppColors.perempuanBg);
      case StatusType.jenisPemberian:
        return _colorsJenisPemberian();
    }
  }

  (Color, Color) _colorsStatusGizi() {
    switch (label.toLowerCase()) {
      case 'normal':
        return (AppColors.statusNormalText, AppColors.statusNormalBg);
      case 'kurang':
        return (AppColors.statusKurangText, AppColors.statusKurangBg);
      case 'buruk':
        return (AppColors.statusBurukText, AppColors.statusBurukBg);
      case 'lebih':
        return (AppColors.statusLebihText, AppColors.statusLebihBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }

  (Color, Color) _colorsKategoriRisiko() {
    switch (label.toLowerCase()) {
      case 'rendah':
        return (AppColors.risikoRendahText, AppColors.risikoRendahBg);
      case 'sedang':
        return (AppColors.risikoSedangText, AppColors.risikoSedangBg);
      case 'tinggi':
        return (AppColors.risikoTinggiText, AppColors.risikoTinggiBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }

  (Color, Color) _colorsStatusRujukan() {
    switch (label.toLowerCase()) {
      case 'diajukan':
        return (AppColors.rujukanDiajukanText, AppColors.rujukanDiajukanBg);
      case 'diterima':
        return (AppColors.rujukanDiterimaText, AppColors.rujukanDiterimaBg);
      case 'dalam_penanganan':
        return (AppColors.rujukanPenangananText, AppColors.rujukanPenangananBg);
      case 'selesai':
        return (AppColors.rujukanSelesaiText, AppColors.rujukanSelesaiBg);
      case 'ditolak':
        return (AppColors.rujukanDitolakText, AppColors.rujukanDitolakBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }

  (Color, Color) _colorsJenisPemberian() {
    switch (label.toLowerCase()) {
      case 'imunisasi':
        return (AppColors.imunisasiText, AppColors.imunisasiBg);
      case 'vitamin_a':
        return (AppColors.vitaminAText, AppColors.vitaminABg);
      case 'obat_cacing':
        return (AppColors.obatCacingText, AppColors.obatCacingBg);
      case 'pmt':
        return (AppColors.pmtText, AppColors.pmtBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }
}
