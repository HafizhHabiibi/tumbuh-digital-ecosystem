import 'package:flutter/material.dart';
import '../../core/constant/app_constants.dart';

String formatStatusAntropometri(String status) {
  switch (status.toLowerCase()) {
    case 'berat_badan_sangat_kurang':
      return 'BB Sangat Kurang';
    case 'berat_badan_kurang':
      return 'BB Kurang';
    case 'berat_badan_normal':
      return 'BB Normal';
    case 'risiko_berat_badan_lebih':
      return 'Risiko BB Lebih';
    case 'sangat_pendek':
      return 'Sangat Pendek';
    case 'pendek':
      return 'Pendek';
    case 'normal':
      return 'Normal';
    case 'tinggi':
      return 'Tinggi';
    case 'gizi_buruk':
      return 'Gizi Buruk';
    case 'gizi_kurang':
      return 'Gizi Kurang';
    case 'gizi_baik':
      return 'Gizi Baik';
    case 'risiko_gizi_lebih':
      return 'Risiko Gizi Lebih';
    case 'gizi_lebih':
      return 'Gizi Lebih';
    case 'obesitas':
      return 'Obesitas';
    default:
      return status;
  }
}

String formatStatusPemantauan(String status) {
  switch (status.toLowerCase()) {
    case 'rutin':
      return 'Pemantauan Rutin';
    case 'perlu_perhatian':
      return 'Perlu Perhatian';
    case 'konsultasi':
      return 'Disarankan Konsultasi';
    default:
      return status;
  }
}

enum StatusType {
  statusAntropometri,
  statusPemantauan,
  kategoriPrioritas,
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
      case StatusType.statusAntropometri:
        return _labelStatusAntropometri();
      case StatusType.statusPemantauan:
        return formatStatusPemantauan(label);
      case StatusType.kategoriPrioritas:
        return _labelKategoriPrioritas();
      case StatusType.statusRujukan:
        return _labelStatusRujukan();
      case StatusType.jenisKelamin:
        return label == 'L' ? 'Laki-laki' : 'Perempuan';
      case StatusType.jenisPemberian:
        return _labelJenisPemberian();
    }
  }

  String _labelStatusAntropometri() {
    return formatStatusAntropometri(label);
  }

  String _labelKategoriPrioritas() {
    switch (label.toLowerCase()) {
      case 'rendah':
        return 'Prioritas Rendah';
      case 'sedang':
        return 'Prioritas Sedang';
      case 'tinggi':
        return 'Prioritas Tinggi';
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
      case 'vitamin_a_merah':
        return 'Vitamin A Merah';
      case 'vitamin_a_biru':
        return 'Vitamin A Biru';
      case 'obat_cacing':
        return 'Obat Cacing';
      case 'pmt_biskuit':
        return 'PMT Biskuit';
      case 'pmt_susu':
        return 'PMT Susu';
      case 'pmt_lainnya':
        return 'PMT Lainnya';
      default:
        return label;
    }
  }

  // ── Colors ────────────────────────────────────

  (Color, Color) _getColors() {
    switch (type) {
      case StatusType.statusAntropometri:
        return _colorsStatusAntropometri();
      case StatusType.statusPemantauan:
        return _colorsStatusPemantauan();
      case StatusType.kategoriPrioritas:
        return _colorsKategoriPrioritas();
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

  (Color, Color) _colorsStatusAntropometri() {
    switch (label.toLowerCase()) {
      case 'berat_badan_normal':
      case 'normal':
      case 'gizi_baik':
        return (AppColors.statusNormalText, AppColors.statusNormalBg);
      case 'berat_badan_kurang':
      case 'pendek':
      case 'gizi_kurang':
      case 'risiko_berat_badan_lebih':
      case 'risiko_gizi_lebih':
        return (AppColors.statusKurangText, AppColors.statusKurangBg);
      case 'berat_badan_sangat_kurang':
      case 'sangat_pendek':
      case 'gizi_buruk':
      case 'obesitas':
        return (AppColors.statusBurukText, AppColors.statusBurukBg);
      case 'tinggi':
      case 'gizi_lebih':
        return (AppColors.statusLebihText, AppColors.statusLebihBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }

  (Color, Color) _colorsKategoriPrioritas() {
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

  (Color, Color) _colorsStatusPemantauan() {
    switch (label.toLowerCase()) {
      case 'rutin':
        return (AppColors.risikoRendahText, AppColors.risikoRendahBg);
      case 'perlu_perhatian':
        return (AppColors.risikoSedangText, AppColors.risikoSedangBg);
      case 'konsultasi':
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
      case 'vitamin_a_merah':
      case 'vitamin_a_biru':
        return (AppColors.vitaminAText, AppColors.vitaminABg);
      case 'obat_cacing':
        return (AppColors.obatCacingText, AppColors.obatCacingBg);
      case 'pmt_biskuit':
      case 'pmt_susu':
      case 'pmt_lainnya':
        return (AppColors.pmtText, AppColors.pmtBg);
      default:
        return (AppColors.textSecondary, AppColors.border);
    }
  }
}
