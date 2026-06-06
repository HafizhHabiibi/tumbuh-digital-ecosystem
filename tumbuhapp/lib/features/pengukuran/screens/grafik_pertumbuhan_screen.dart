import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/pengukuran_provider.dart';
import '../providers/who_standards_provider.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/models/anak_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/status_badge_widget.dart';

class GrafikPertumbuhanScreen extends ConsumerStatefulWidget {
  final String anakId;

  const GrafikPertumbuhanScreen({super.key, required this.anakId});

  @override
  ConsumerState<GrafikPertumbuhanScreen> createState() =>
      _GrafikPertumbuhanScreenState();
}

class _GrafikPertumbuhanScreenState
    extends ConsumerState<GrafikPertumbuhanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateAgeInMonths(String tanggalLahir, String tanggalUkur) {
    try {
      final lahir = DateTime.parse(tanggalLahir);
      final ukur = DateTime.parse(tanggalUkur);
      final age = (ukur.year - lahir.year) * 12 + (ukur.month - lahir.month);
      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riwayatAsync = ref.watch(riwayatPengukuranProvider(widget.anakId));
    final whoTablesAsync = ref.watch(whoTablesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Grafik Pertumbuhan KMS', style: AppTextStyles.heading3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'BB/U (KMS)'),
            Tab(text: 'TB/U (Stunting)'),
            Tab(text: 'BB/TB (Ideal)'),
          ],
        ),
      ),
      body: whoTablesAsync.when(
        loading: () => const ShimmerList(itemCount: 3, itemHeight: 200),
        error: (err, _) => ErrorStateWidget(
          message: 'Gagal memuat standar WHO: ${err.toString()}',
          onRetry: () => ref.refresh(whoTablesProvider),
        ),
        data: (tables) {
          return riwayatAsync.when(
            loading: () => const ShimmerList(itemCount: 3, itemHeight: 200),
            error: (err, _) => ErrorStateWidget(
              message: err.toString(),
              onRetry: () => ref.refresh(riwayatPengukuranProvider(widget.anakId)),
            ),
            data: (data) {
              final riwayat = data.riwayat;

              if (riwayat.isEmpty) return const EmptyGrafik();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildGrafikTab(data.anak, riwayat, tables, 'bbu'),
                  _buildGrafikTab(data.anak, riwayat, tables, 'tbu'),
                  _buildGrafikTab(data.anak, riwayat, tables, 'bbtb'),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ── Grafik Tab ────────────────────────────────

  Widget _buildGrafikTab(
    AnakModel anak,
    List<PengukuranModel> riwayat,
    Map<String, dynamic> tables,
    String type,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Grafik ────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGrafikTitle(type),
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  _getGrafikSubtitle(type),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                _buildLegend(type),
                const SizedBox(height: 20),
                // Indikator Unit Sumbu X & Y agar tidak bertumpuk di dalam grafik
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sumbu Y: ${type == 'tbu' ? 'Tinggi (cm)' : 'Berat (kg)'}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sumbu X: ${type == 'bbtb' ? 'Tinggi Badan (cm)' : 'Usia (Bulan)'}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: _buildLineChart(anak, riwayat, tables, type),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tabel Riwayat ─────────────────
          Text('Riwayat Data', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _buildTabel(riwayat, type),
        ],
      ),
    );
  }

  // ── Line Chart ────────────────────────────────

  Widget _buildLineChart(
    AnakModel anak,
    List<PengukuranModel> riwayat,
    Map<String, dynamic> tables,
    String type,
  ) {
    // Urutkan dari terlama ke terbaru
    final sorted = [...riwayat]
      ..sort((a, b) => a.tanggalUkur.compareTo(b.tanggalUkur));

    // 1. Tentukan range X-axis dan Y-axis
    int maxAgeInMonths = 24;
    for (final p in sorted) {
      final age = _calculateAgeInMonths(anak.tanggalLahir, p.tanggalUkur);
      if (age > maxAgeInMonths) {
        maxAgeInMonths = age;
      }
    }
    // Batasi maksimum 60 bulan sesuai dengan dataset standar WHO
    maxAgeInMonths = math.min(60, maxAgeInMonths + 3);

    // X values & Y values child data
    final dataSpots = sorted.map((p) {
      final x = type == 'bbtb'
          ? p.tinggiBadan
          : _calculateAgeInMonths(anak.tanggalLahir, p.tanggalUkur).toDouble();
      final y = type == 'tbu' ? p.tinggiBadan : p.beratBadan;
      return FlSpot(x, y);
    }).toList();

    // 2. Generate Curves dari WHO Tables
    Map<double, List<FlSpot>> curves = {};
    double minX = 0.0;
    double maxX = maxAgeInMonths.toDouble();

    if (type == 'bbtb') {
      // Tentukan tabel BB/TB (wfl untuk < 2 tahun, wfh untuk >= 2 tahun)
      final latestAge = riwayat.isNotEmpty
          ? _calculateAgeInMonths(anak.tanggalLahir, sorted.last.tanggalUkur)
          : _calculateAgeInMonths(anak.tanggalLahir, DateTime.now().toIso8601String().substring(0, 10));
      final useWfl = latestAge < 24;

      minX = useWfl ? 45.0 : 65.0;
      maxX = useWfl ? 110.0 : 120.0;

      if (sorted.isNotEmpty) {
        final childMinH = sorted.map((p) => p.tinggiBadan).reduce(math.min);
        final childMaxH = sorted.map((p) => p.tinggiBadan).reduce(math.max);
        minX = math.max(useWfl ? 45.0 : 65.0, childMinH - 5.0);
        maxX = math.min(useWfl ? 110.0 : 120.0, childMaxH + 5.0);
      }

      curves = WhoStandards.getBbtbCurves(
        tables: tables,
        jenisKelamin: anak.jenisKelamin,
        minHeight: minX,
        maxHeight: maxX,
        useWfl: useWfl,
      );
    } else {
      curves = WhoStandards.getBbuTbuCurves(
        tables: tables,
        type: type,
        jenisKelamin: anak.jenisKelamin,
        minMonth: 0,
        maxMonth: maxAgeInMonths,
      );
    }

    // Tentukan range Y
    double minY = type == 'tbu' ? 40.0 : 0.0;
    double maxY = type == 'tbu' ? 120.0 : 15.0;

    // Filter kurva yang relevan dan hitung range Y
    final List<double> activeZs = [];
    if (type == 'bbu') {
      activeZs.addAll([-3.0, -2.0, 0.0, 2.0]);
    } else if (type == 'tbu') {
      activeZs.addAll([-3.0, -2.0, 0.0]);
    } else {
      activeZs.addAll([-2.0, 0.0, 2.0]);
    }

    final List<FlSpot> allReferenceSpots = [];
    for (final z in activeZs) {
      if (curves[z] != null) {
        allReferenceSpots.addAll(curves[z]!);
      }
    }

    if (allReferenceSpots.isNotEmpty) {
      minY = allReferenceSpots.map((s) => s.y).reduce(math.min) - (type == 'tbu' ? 3.0 : 1.0);
      if (minY < 0) minY = 0.0;
      if (type == 'tbu' && minY < 30.0) minY = 30.0;

      maxY = allReferenceSpots.map((s) => s.y).reduce(math.max) + (type == 'tbu' ? 5.0 : 2.0);
    }

    if (dataSpots.isNotEmpty) {
      final childMinY = dataSpots.map((s) => s.y).reduce(math.min) - (type == 'tbu' ? 3.0 : 1.0);
      final childMaxY = dataSpots.map((s) => s.y).reduce(math.max) + (type == 'tbu' ? 5.0 : 2.0);
      if (childMinY < minY && childMinY >= 0) minY = childMinY;
      if (childMaxY > maxY) maxY = childMaxY;
    }

    // Set Axis Intervals
    final double leftInterval = type == 'tbu' ? 10.0 : 2.0;
    final double bottomInterval = type == 'bbtb' ? 5.0 : (maxAgeInMonths > 36 ? 6.0 : 3.0);

    // Build line bars and trace indexes for betweenBarsData shading
    final barDataList = <LineChartBarData>[];
    final betweenBarsList = <BetweenBarsData>[];
    
    int? bbuLowIndex;
    int? bbuHighIndex;
    int? tbuLowIndex;
    int? tbuHighIndex;
    int? bbtbLowIndex;
    int? bbtbHighIndex;

    curves.forEach((z, spots) {
      if (spots.isNotEmpty) {
        if (!activeZs.contains(z)) return;

        final color = _getCurveColor(z, type);
        final currentIndex = barDataList.length;

        if (type == 'bbu') {
          if (z == -2.0) bbuLowIndex = currentIndex;
          if (z == 2.0) bbuHighIndex = currentIndex;
        } else if (type == 'tbu') {
          if (z == -3.0) tbuLowIndex = currentIndex;
          if (z == -2.0) tbuHighIndex = currentIndex;
        } else if (type == 'bbtb') {
          if (z == -2.0) bbtbLowIndex = currentIndex;
          if (z == 2.0) bbtbHighIndex = currentIndex;
        }

        barDataList.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color.withValues(alpha: 0.5),
            barWidth: z == 0.0 ? 2.0 : 1.2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        );
      }
    });

    // Add Area Shading between curves
    if (type == 'bbu' && bbuLowIndex != null && bbuHighIndex != null) {
      betweenBarsList.add(
        BetweenBarsData(
          fromIndex: bbuLowIndex!,
          toIndex: bbuHighIndex!,
          color: const Color(0xFF15803D).withValues(alpha: 0.06), // Soft Green (Normal Zone)
        ),
      );
    } else if (type == 'tbu' && tbuLowIndex != null && tbuHighIndex != null) {
      betweenBarsList.add(
        BetweenBarsData(
          fromIndex: tbuLowIndex!,
          toIndex: tbuHighIndex!,
          color: const Color(0xFFDC2626).withValues(alpha: 0.05), // Soft Red (Stunting Risk Zone)
        ),
      );
    } else if (type == 'bbtb' && bbtbLowIndex != null && bbtbHighIndex != null) {
      betweenBarsList.add(
        BetweenBarsData(
          fromIndex: bbtbLowIndex!,
          toIndex: bbtbHighIndex!,
          color: const Color(0xFF0EA5E9).withValues(alpha: 0.06), // Soft Sky Blue (Ideal Zone)
        ),
      );
    }

    // Garis data anak (digambar paling terakhir agar paling atas)
    barDataList.add(
      LineChartBarData(
        spots: dataSpots,
        isCurved: true,
        color: AppColors.primary,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
            radius: 5,
            color: AppColors.primary,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: leftInterval,
          verticalInterval: bottomInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider,
            strokeWidth: 0.5,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppColors.divider,
            strokeWidth: 0.5,
          ),
        ),
        betweenBarsData: betweenBarsList,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: leftInterval,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
          ),
        ),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: barDataList,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                // spot.barIndex == barDataList.length - 1 mewakili data anak
                if (spot.barIndex == barDataList.length - 1) {
                  final index = spot.spotIndex;
                  if (index >= 0 && index < sorted.length) {
                    final p = sorted[index];
                    String valueStr = '';
                    String zScoreStr = '';
                    if (type == 'bbu') {
                      valueStr = FormatUtils.formatBeratBadan(p.beratBadan);
                      zScoreStr = FormatUtils.formatZScore(p.zscoreBbu);
                    } else if (type == 'tbu') {
                      valueStr = FormatUtils.formatTinggiBadan(p.tinggiBadan);
                      zScoreStr = FormatUtils.formatZScore(p.zscoreTbu);
                    } else {
                      valueStr = FormatUtils.formatBeratBadan(p.beratBadan);
                      zScoreStr = FormatUtils.formatZScore(p.zscoreBbtb);
                    }

                    return LineTooltipItem(
                      '$valueStr ($zScoreStr)\n'
                      '${_formatTanggalSingkat(p.tanggalUkur)}',
                      AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ── Legend ────────────────────────────────────

  Widget _buildLegend(String type) {
    if (type == 'bbu') {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: AppColors.primary,
            label: 'Data Anak',
            isDashed: false,
            isThick: true,
          ),
          _buildLegendItem(
            color: const Color(0xFF15803D),
            label: 'Median (0 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFD97706),
            label: 'Batas Normal (±2 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFDC2626),
            label: 'Bawah Garis Merah (-3 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFF15803D).withValues(alpha: 0.15),
            label: 'Zona Normal (Pita Hijau)',
            isShadedBox: true,
          ),
        ],
      );
    } else if (type == 'tbu') {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: AppColors.primary,
            label: 'Data Anak',
            isDashed: false,
            isThick: true,
          ),
          _buildLegendItem(
            color: const Color(0xFF15803D),
            label: 'Tinggi Normal (0 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFD97706),
            label: 'Batas Pendek (-2 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFDC2626),
            label: 'Sangat Pendek (-3 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFDC2626).withValues(alpha: 0.15),
            label: 'Zona Risiko Stunting',
            isShadedBox: true,
          ),
        ],
      );
    } else {
      // type == 'bbtb'
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: AppColors.primary,
            label: 'Data Anak',
            isDashed: false,
            isThick: true,
          ),
          _buildLegendItem(
            color: const Color(0xFF0EA5E9),
            label: 'Berat Ideal (0 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFF6366F1),
            label: 'Batas Gemuk (+2 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFFD97706),
            label: 'Batas Kurus (-2 SD)',
            isDashed: false,
          ),
          _buildLegendItem(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
            label: 'Zona Proporsi Ideal',
            isShadedBox: true,
          ),
        ],
      );
    }
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    bool isThick = false,
    bool isShadedBox = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 12,
          child: isShadedBox
              ? Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : Center(
                  child: isDashed
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 1.5, color: color),
                            const SizedBox(width: 2),
                            Container(width: 8, height: 1.5, color: color),
                          ],
                        )
                      : Container(
                          height: isThick ? 3.5 : 2.0,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  // ── Tabel Riwayat ─────────────────────────────

  Widget _buildTabel(List<PengukuranModel> riwayat, String type) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header tabel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tanggal',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    type == 'bbu'
                        ? 'BB'
                        : type == 'tbu'
                            ? 'TB'
                            : 'BB',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Z-Score',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...riwayat.asMap().entries.map((entry) {
            final index = entry.key;
            final p = entry.value;
            final isLast = index == riwayat.length - 1;
            final zscore = _getYValue(p, type);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          FormatUtils.formatTanggal(p.tanggalUkur),
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          type == 'bbu'
                              ? FormatUtils.formatBeratBadan(p.beratBadan)
                              : type == 'tbu'
                                  ? FormatUtils.formatTinggiBadan(p.tinggiBadan)
                                  : FormatUtils.formatBeratBadan(p.beratBadan),
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          FormatUtils.formatZScore(zscore),
                          style: AppTextStyles.caption.copyWith(
                            color: _getZScoreColor(zscore),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: StatusBadge(
                            label: p.statusGizi,
                            type: StatusType.statusGizi,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────

  double _getYValue(PengukuranModel p, String type) {
    switch (type) {
      case 'bbu':
        return p.zscoreBbu;
      case 'tbu':
        return p.zscoreTbu;
      case 'bbtb':
        return p.zscoreBbtb;
      default:
        return 0;
    }
  }

  String _getGrafikTitle(String type) {
    switch (type) {
      case 'bbu':
        return 'Berat Badan / Umur';
      case 'tbu':
        return 'Tinggi Badan / Umur';
      case 'bbtb':
        return 'Berat Badan / Tinggi Badan';
      default:
        return '';
    }
  }

  String _getGrafikSubtitle(String type) {
    switch (type) {
      case 'bbu':
        return 'Grafik Berat Badan (kg) menurut Umur (Bulan) berdasarkan standar WHO';
      case 'tbu':
        return 'Grafik Tinggi Badan (cm) menurut Umur (Bulan) berdasarkan standar WHO';
      case 'bbtb':
        return 'Grafik Berat Badan (kg) menurut Tinggi Badan (cm) berdasarkan standar WHO';
      default:
        return '';
    }
  }

  String _formatTanggalSingkat(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
    } catch (_) {
      return '-';
    }
  }

  Color _getZScoreColor(double zscore) {
    if (zscore < -2 || zscore > 2) return AppColors.statusBurukText;
    if (zscore < -1 || zscore > 1) return AppColors.statusKurangText;
    return AppColors.statusNormalText;
  }

  Color _getCurveColor(double z, String type) {
    if (type == 'bbu') {
      if (z == -3.0) return const Color(0xFFDC2626); // Red (BGM)
      if (z == -2.0) return const Color(0xFFD97706); // Orange
      if (z == 0.0) return const Color(0xFF15803D);  // Green (Median)
      if (z == 2.0) return const Color(0xFFD97706);  // Orange
    } else if (type == 'tbu') {
      if (z == -3.0) return const Color(0xFFDC2626); // Red (Sangat Pendek)
      if (z == -2.0) return const Color(0xFFD97706); // Orange (Pendek)
      if (z == 0.0) return const Color(0xFF15803D);  // Green (Normal)
    } else if (type == 'bbtb') {
      if (z == -2.0) return const Color(0xFFD97706); // Orange (Kurus)
      if (z == 0.0) return const Color(0xFF0EA5E9);  // Sky Blue (Ideal)
      if (z == 2.0) return const Color(0xFF6366F1);  // Indigo (Gemuk)
    }
    return const Color(0xFF94A3B8);
  }
}
