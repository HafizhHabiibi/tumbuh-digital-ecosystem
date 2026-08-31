import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constant/app_constants.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/models/pengukuran_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/status_badge_widget.dart';
import '../providers/pengukuran_provider.dart';

class GrafikPertumbuhanScreen extends ConsumerWidget {
  final String anakId;

  const GrafikPertumbuhanScreen({super.key, required this.anakId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatAsync = ref.watch(riwayatPengukuranProvider(anakId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Grafik Pertumbuhan', style: AppTextStyles.heading3),
      ),
      body: riwayatAsync.when(
        loading: () => const ShimmerList(itemCount: 3, itemHeight: 220),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(riwayatPengukuranProvider(anakId)),
        ),
        data: (data) {
          if (data.riwayat.isEmpty) return const EmptyGrafik();

          final sorted = [...data.riwayat]
            ..sort((a, b) => a.tanggalUkur.compareTo(b.tanggalUkur));

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref
                .refresh(riwayatPengukuranProvider(anakId).future)
                .then<void>((_) {}),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildInformationCard(),
                const SizedBox(height: 16),
                _buildChartCard(sorted, _GrowthMetric.weight),
                const SizedBox(height: 16),
                _buildChartCard(sorted, _GrowthMetric.height),
                const SizedBox(height: 24),
                _buildGrowthSummaryCard(context, ref, sorted),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.show_chart, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Grafik menunjukkan perubahan berat dan tinggi badan berdasarkan tanggal pengukuran.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    List<PengukuranModel> measurements,
    _GrowthMetric metric,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            '${metric.unitName} berdasarkan tanggal pengukuran',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(metric.legend, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _buildLineChart(measurements, metric),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tanggal pengukuran',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<PengukuranModel> measurements,
    _GrowthMetric metric,
  ) {
    final values = measurements.map(metric.value).toList();
    final minimumValue = values.reduce(math.min);
    final maximumValue = values.reduce(math.max);
    final valueRange = maximumValue - minimumValue;
    final padding = math.max(
      valueRange * 0.2,
      metric == _GrowthMetric.weight ? 1.0 : 5.0,
    );
    final minY = math.max(0.0, minimumValue - padding);
    final maxY = maximumValue + padding;
    final horizontalInterval = math.max((maxY - minY) / 4, 0.5);
    final maxX = math.max(1, measurements.length - 1).toDouble();
    final labelInterval = math.max(1, (measurements.length / 5).ceil());

    final spots = measurements.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), metric.value(entry.$2)))
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.divider,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              metric.shortUnit,
              style: AppTextStyles.caption.copyWith(fontSize: 9),
            ),
            axisNameSize: 18,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: horizontalInterval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                space: 6,
                child: Text(
                  _formatAxisValue(value),
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                final isInteger = (value - index).abs() < 0.01;
                final isVisible = index % labelInterval == 0 ||
                    index == measurements.length - 1;
                if (!isInteger ||
                    index < 0 ||
                    index >= measurements.length ||
                    !isVisible) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    _formatChartDate(measurements[index].tanggalUkur),
                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: measurements.length > 2,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4.5,
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
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.spotIndex;
              if (index < 0 || index >= measurements.length) return null;
              final measurement = measurements[index];
              return LineTooltipItem(
                '${FormatUtils.formatTanggal(measurement.tanggalUkur)}\n'
                '${metric.valueLabel}: ${metric.formattedValue(measurement)}\n'
                '${metric.statusLabel}: ${formatStatusAntropometri(metric.status(measurement))}',
                AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthSummaryCard(
    BuildContext context,
    WidgetRef ref,
    List<PengukuranModel> measurements,
  ) {
    final latest = measurements.last;
    final previous =
        measurements.length > 1 ? measurements[measurements.length - 2] : null;

    return Container(
      key: const ValueKey('growth-change-summary'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ringkasan Perubahan Terakhir',
                  style: AppTextStyles.heading3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pengukuran terakhir ${FormatUtils.formatTanggal(latest.tanggalUkur)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          if (previous == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Belum cukup data untuk melihat perubahan pertumbuhan.',
                style: AppTextStyles.bodySecondary,
              ),
            )
          else ...[
            Text(
              _comparisonPeriod(previous, latest),
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildChangeItem(
                    label: 'Berat Badan',
                    change: latest.beratBadan - previous.beratBadan,
                    currentValue:
                        FormatUtils.formatBeratBadan(latest.beratBadan),
                    unit: 'KG',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChangeItem(
                    label: 'Tinggi Badan',
                    change: latest.tinggiBadan - previous.tinggiBadan,
                    currentValue:
                        FormatUtils.formatTinggiBadan(latest.tinggiBadan),
                    unit: 'CM',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('open-latest-measurement'),
              onPressed: () {
                ref.read(selectedPengukuranProvider.notifier).state = latest;
                context.push('/pengukuran/${latest.id}');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Lihat detail pengukuran terbaru'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeItem({
    required String label,
    required double change,
    required String currentValue,
    required String unit,
  }) {
    final direction = change > 0
        ? 'Naik'
        : change < 0
            ? 'Turun'
            : 'Tetap';
    final icon = change > 0
        ? Icons.arrow_upward_rounded
        : change < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$direction ${_formatChange(change)} $unit',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Menjadi $currentValue', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _comparisonPeriod(
    PengukuranModel previous,
    PengukuranModel latest,
  ) {
    final previousDate = DateTime.parse(previous.tanggalUkur);
    final latestDate = DateTime.parse(latest.tanggalUkur);
    final days = latestDate.difference(previousDate).inDays;
    if (days == 0) {
      return 'Dibandingkan pengukuran sebelumnya pada hari yang sama';
    }
    return 'Dibandingkan dengan pengukuran $days hari sebelumnya';
  }

  String _formatChange(double value) {
    final absolute = value.abs();
    if (absolute == absolute.roundToDouble()) {
      return absolute.toInt().toString();
    }
    return absolute.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatAxisValue(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatChartDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return '-';
    return '${date.day}/${date.month}';
  }
}

enum _GrowthMetric { weight, height }

extension on _GrowthMetric {
  String get title => switch (this) {
        _GrowthMetric.weight => 'Perkembangan Berat Badan',
        _GrowthMetric.height => 'Perkembangan Tinggi Badan',
      };

  String get unitName => switch (this) {
        _GrowthMetric.weight => 'Berat badan dalam kilogram',
        _GrowthMetric.height => 'Tinggi badan dalam sentimeter',
      };

  String get shortUnit => switch (this) {
        _GrowthMetric.weight => 'KG',
        _GrowthMetric.height => 'CM',
      };

  String get legend => switch (this) {
        _GrowthMetric.weight => 'Berat badan anak',
        _GrowthMetric.height => 'Tinggi badan anak',
      };

  String get valueLabel => switch (this) {
        _GrowthMetric.weight => 'Berat badan',
        _GrowthMetric.height => 'Tinggi badan',
      };

  String get statusLabel => switch (this) {
        _GrowthMetric.weight => 'Status BB/U',
        _GrowthMetric.height => 'Status TB/U',
      };

  double value(PengukuranModel measurement) => switch (this) {
        _GrowthMetric.weight => measurement.beratBadan,
        _GrowthMetric.height => measurement.tinggiBadan,
      };

  String status(PengukuranModel measurement) => switch (this) {
        _GrowthMetric.weight => measurement.statusBbu,
        _GrowthMetric.height => measurement.statusTbu,
      };

  String formattedValue(PengukuranModel measurement) => switch (this) {
        _GrowthMetric.weight =>
          FormatUtils.formatBeratBadan(measurement.beratBadan),
        _GrowthMetric.height =>
          FormatUtils.formatTinggiBadan(measurement.tinggiBadan),
      };
}
