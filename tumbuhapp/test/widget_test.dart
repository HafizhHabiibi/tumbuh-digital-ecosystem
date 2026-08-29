import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/main.dart';

void main() {
  testWidgets('menampilkan kesalahan konfigurasi sebelum startup',
      (tester) async {
    await tester.pumpWidget(
      const ConfigurationErrorApp(
        message: 'API_BASE_URL belum dikonfigurasi.',
      ),
    );

    expect(find.text('Konfigurasi aplikasi tidak valid'), findsOneWidget);
    expect(find.text('API_BASE_URL belum dikonfigurasi.'), findsOneWidget);
  });
}
