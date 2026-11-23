import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Login screen renders and opens student role', (tester) async {
    await tester.pumpWidget(const PreslocApp());

    expect(find.text('PRESLOC'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda Siswa'), findsOneWidget);
  });

  testWidgets('Guru role opens dashboard', (tester) async {
    await tester.pumpWidget(const PreslocApp());

    await tester.tap(find.text('Guru BK'));
    await tester.pump();
    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Guru BK'), findsOneWidget);
  });
}
