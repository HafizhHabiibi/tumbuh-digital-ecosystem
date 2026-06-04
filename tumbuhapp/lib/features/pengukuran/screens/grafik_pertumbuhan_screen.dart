import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/pengukuran_provider.dart';
import '../../../shared/models/pengukuran_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final riwayatAsync = ref.watch(riwayatPengukuranProvider(widget.anakId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Grafik Pertumbuhan', style: AppTextStyles.heading3),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'BB/U'),
            Tab(text: 'TB/U'),
            Tab(text: 'BB/TB'),
          ],
        ),
      ),
      body: riwayatAsync.when(
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
              _buildGrafikTab(riwayat, 'bbu'),
              _buildGrafikTab(riwayat, 'tbu'),
              _buildGrafikTab(riwayat, 'bbtb'),
            ],
          );
        },
      ),
    );
  }

  // ── Grafik Tab ────────────────────────────────

  Widget _buildGrafikTab(List<PengukuranModel> riwayat, String type) {
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
                _buildLegend(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: _buildLineChart(riwayat, type),
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

  Widget _buildLineChart(List<PengukuranModel> riwayat, String type) {
    // Urutkan dari terlama ke terbaru untuk grafik
    final sorted = [...riwayat]
      ..sort((a, b) => a.tanggalUkur.compareTo(b.tanggalUkur));

    final dataSpots = sorted.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final p = entry.value;
      final y = _getYValue(p, type);
      return FlSpot(index, y);
    }).toList();

    // Garis referensi WHO
    final refNormal =
        sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), 0)).toList();
    final refPlus2 =
        sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), 2)).toList();
    final refMinus2 = sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), -2))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: AppTextStyles.caption,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTanggalSingkat(sorted[index].tanggalUkur),
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
        minY: -4,
        maxY: 4,
        lineBarsData: [
          // Garis data anak
          LineChartBarData(
            spots: dataSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),

          // Garis referensi +2 SD
          LineChartBarData(
            spots: refPlus2,
            isCurved: false,
            color: AppColors.statusKurangText.withValues(alpha: 0.5),
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          ),

          // Garis referensi 0 (median)
          LineChartBarData(
            spots: refNormal,
            isCurved: false,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          ),

          // Garis referensi -2 SD
          LineChartBarData(
            spots: refMinus2,
            isCurved: false,
            color: AppColors.statusBurukText.withValues(alpha: 0.5),
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                if (spot.barIndex == 0) {
                  final index = spot.x.toInt();
                  if (index < sorted.length) {
                    return LineTooltipItem(
                      '${FormatUtils.formatZScore(spot.y)}\n'
                      '${_formatTanggalSingkat(sorted[index].tanggalUkur)}',
                      AppTextStyles.caption.copyWith(color: Colors.white),
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

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          color: AppColors.primary,
          label: 'Data Anak',
          isDashed: false,
        ),
        _buildLegendItem(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          label: 'Median (0 SD)',
          isDashed: true,
        ),
        _buildLegendItem(
          color: AppColors.statusKurangText.withValues(alpha: 0.6),
          label: '+2 SD',
          isDashed: true,
        ),
        _buildLegendItem(
          color: AppColors.statusBurukText.withValues(alpha: 0.6),
          label: '-2 SD',
          isDashed: true,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isDashed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          child: isDashed
              ? Row(
                  children: [
                    Container(width: 8, height: 2, color: color),
                    const SizedBox(width: 2),
                    Container(width: 8, height: 2, color: color),
                  ],
                )
              : Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
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
        return 'Z-Score BB/U berdasarkan standar WHO';
      case 'tbu':
        return 'Z-Score TB/U berdasarkan standar WHO';
      case 'bbtb':
        return 'Z-Score BB/TB berdasarkan standar WHO';
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
}
