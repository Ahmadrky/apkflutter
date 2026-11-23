import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Login screen renders and opens student role', (tester) async {
    await tester.pumpWidget(const PreslocApp());
    await tester.pumpAndSettle();

    expect(find.text('PRESLOC'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '0064629105');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda Siswa'), findsOneWidget);
  });

  testWidgets('Guru role opens dashboard', (tester) async {
    await tester.pumpWidget(const PreslocApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'guru@presloc');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Guru BK'));
    await tester.pump();
    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard Guru BK'), findsOneWidget);
  });
}
