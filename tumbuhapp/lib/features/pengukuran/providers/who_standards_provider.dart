import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

final whoTablesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/whoTables.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
});

class WhoStandards {
  WhoStandards._();

  static double calculateLmsValue(double L, double M, double S, double Z) {
    if (L == 0.0) {
      return M * exp(S * Z);
    } else {
      return M * pow(1.0 + L * S * Z, 1.0 / L);
    }
  }

  static Map<double, List<FlSpot>> getBbuTbuCurves({
    required Map<String, dynamic> tables,
    required String type,
    required String jenisKelamin,
    required int minMonth,
    required int maxMonth,
  }) {
    final key = '${type}_${jenisKelamin == 'L' ? 'L' : 'P'}';
    final list = tables[key] as List<dynamic>?;
    if (list == null) return {};

    final Map<double, List<FlSpot>> curves = {
      -3.0: [],
      -2.0: [],
      -1.0: [],
      0.0: [],
      1.0: [],
      2.0: [],
      3.0: [],
    };

    for (final row in list) {
      final int bulan = row['bulan'] as int;
      if (bulan < minMonth || bulan > maxMonth) continue;

      final double L = double.tryParse(row['L'].toString()) ?? 0.0;
      final double M = double.tryParse(row['M'].toString()) ?? 0.0;
      final double S = double.tryParse(row['S'].toString()) ?? 0.0;

      for (final z in curves.keys) {
        final y = calculateLmsValue(L, M, S, z);
        curves[z]!.add(FlSpot(bulan.toDouble(), y));
      }
    }

    return curves;
  }

  static Map<double, List<FlSpot>> getBbtbCurves({
    required Map<String, dynamic> tables,
    required String jenisKelamin,
    required double minHeight,
    required double maxHeight,
    required bool useWfl,
  }) {
    final prefix = useWfl ? 'wfl' : 'wfh';
    final key = '${prefix}_${jenisKelamin == 'L' ? 'L' : 'P'}';
    final list = tables[key] as List<dynamic>?;
    if (list == null) return {};

    final Map<double, List<FlSpot>> curves = {
      -3.0: [],
      -2.0: [],
      -1.0: [],
      0.0: [],
      1.0: [],
      2.0: [],
      3.0: [],
    };

    for (final row in list) {
      final double h =
          double.tryParse((row['panjang'] ?? row['tinggi']).toString()) ?? 0.0;
      if (h < minHeight || h > maxHeight) continue;

      // Sample every 0.5 cm to ensure smooth lines and efficient rendering
      if ((h * 10).round() % 5 != 0) continue;

      final double L = double.tryParse(row['L'].toString()) ?? 0.0;
      final double M = double.tryParse(row['M'].toString()) ?? 0.0;
      final double S = double.tryParse(row['S'].toString()) ?? 0.0;

      for (final z in curves.keys) {
        final y = calculateLmsValue(L, M, S, z);
        curves[z]!.add(FlSpot(h, y));
      }
    }

    return curves;
  }
}
