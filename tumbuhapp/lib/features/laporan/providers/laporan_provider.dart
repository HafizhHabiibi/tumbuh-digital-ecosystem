import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/laporan_service.dart';

final laporanServiceProvider = Provider<LaporanService>((ref) {
  return LaporanService();
});
