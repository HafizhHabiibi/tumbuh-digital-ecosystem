import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tumbuhapp/core/utils/format_utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id');
  });

  test('format tanggal kalender tidak menggeser tanggal pengukuran', () {
    expect(FormatUtils.formatTanggal('2026-09-03'), '3 September 2026');
    expect(
      FormatUtils.formatTanggalLengkap('2026-09-03'),
      'Kamis, 3 September 2026',
    );
  });

  test('format tanggal menolak tanggal kalender yang tidak valid', () {
    expect(FormatUtils.formatTanggal('2026-02-30'), '-');
  });
}
