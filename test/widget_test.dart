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

  testWidgets('el botón de tema recorre sistema, claro y oscuro', (
    tester,
  ) async {
    // 1. Construir Wallet UNSAAC.
    await tester.pumpWidget(
      const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
    );

    await tester.pumpAndSettle();

    // Obtener el MaterialApp actual.
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Localizar el botón de cambio de tema.
    final themeButton = find.byKey(const Key('theme_cycle_button'));

    // 2. Verificar el modo inicial.
    expect(app().themeMode, ThemeMode.system);

    expect(find.byTooltip('Tema del sistema. Cambiar a claro'), findsOneWidget);

    // 3. Primer toque: Sistema → Claro.
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.light);

    expect(find.byTooltip('Tema claro. Cambiar a oscuro'), findsOneWidget);

    // 4. Segundo toque: Claro → Oscuro.
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.dark);

    expect(find.byTooltip('Tema oscuro. Cambiar a sistema'), findsOneWidget);

    // 5. Tercer toque: Oscuro → Sistema.
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.system);

    expect(find.byTooltip('Tema del sistema. Cambiar a claro'), findsOneWidget);
  });
}
