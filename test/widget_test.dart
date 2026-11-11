import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';

void main() {
  testWidgets('la pantalla principal muestra el saldo de demostración', (
    tester,
  ) async {
    await tester.pumpWidget(
      const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wallet UNSAAC'), findsOneWidget);
    expect(find.text('Saldo disponible'), findsOneWidget);
    expect(find.text('S/ 1,274.60'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Firebase: no configurado (modo local)'),
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase: no configurado (modo local)'), findsOneWidget);
  });

  testWidgets('el botón de tema alterna MaterialApp a modo oscuro', (
    tester,
  ) async {
    await tester.pumpWidget(
      const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
    );
    await tester.pumpAndSettle();

    MaterialApp app() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app().themeMode, ThemeMode.system);

    await tester.tap(find.byTooltip('Activar tema oscuro'));
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.dark);
    expect(find.byTooltip('Activar tema claro'), findsOneWidget);
  });
}
