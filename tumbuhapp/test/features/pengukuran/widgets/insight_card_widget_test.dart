import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';
import 'package:tumbuhapp/shared/widgets/insight_card_widget.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('menampilkan proses analisis untuk status pending',
      (tester) async {
    await tester.pumpWidget(
      _app(const InsightCard(status: InsightStatus.pending)),
    );

    expect(find.text('Sedang menganalisis data anak...'), findsOneWidget);
  });

  testWidgets('menampilkan kegagalan dan tombol periksa kembali',
      (tester) async {
    var refreshed = false;
    await tester.pumpWidget(
      _app(InsightCard(
        status: InsightStatus.failed,
        onRefresh: () => refreshed = true,
      )),
    );

    expect(find.text('Insight belum dapat tersedia saat ini.'), findsOneWidget);
    await tester.tap(find.text('Periksa kembali'));
    expect(refreshed, isTrue);
  });

  testWidgets('menampilkan error jaringan secara eksplisit', (tester) async {
    await tester.pumpWidget(
      _app(const InsightCard(errorMessage: 'Tidak dapat terhubung ke server')),
    );

    expect(find.text('Tidak dapat terhubung ke server'), findsOneWidget);
    expect(find.text('Insight belum tersedia untuk pengukuran ini.'),
        findsNothing);
  });
}
