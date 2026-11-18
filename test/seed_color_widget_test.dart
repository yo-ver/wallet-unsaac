import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

void main() {
  // Colores utilizados durante las pruebas.
  const blue = Color(0xFF1565C0);
  const green = Color(0xFF2E7D32);

  group('Reto 4 - Pruebas de widgets del selector', () {
    // PRUEBA 1: Abrir el selector y seleccionar azul.
    testWidgets('Permite seleccionar azul y actualizar la interfaz', (
      WidgetTester tester,
    ) async {
      // 1. Construir Wallet UNSAAC en modo claro.
      await tester.pumpWidget(
        const WalletApp(
          firebaseStatus: FirebaseStatus.notConfigured(),
          initialThemeMode: ThemeMode.light,
        ),
      );

      // Esperar a que se cargue el resumen financiero.
      await tester.pumpAndSettle();

      // 2. Localizar el botón de personalización.
      final pickerButton = find.byKey(const Key('seed_color_picker_button'));

      expect(pickerButton, findsOneWidget);

      // 3. Abrir el selector.
      await tester.tap(pickerButton);
      await tester.pumpAndSettle();

      // Verificar el título.
      expect(find.text('Personalizar color'), findsOneWidget);

      // Comprobar que aparecen las cuatro opciones.
      expect(find.byKey(const Key('seed_color_granate')), findsOneWidget);

      expect(find.byKey(const Key('seed_color_azul')), findsOneWidget);

      expect(find.byKey(const Key('seed_color_verde')), findsOneWidget);

      expect(find.byKey(const Key('seed_color_morado')), findsOneWidget);

      // 4. Verificar el color seleccionado inicialmente.
      final initialOption = tester.widget<ListTile>(
        find.byKey(const Key('seed_color_granate')),
      );

      expect(initialOption.selected, isTrue);

      // 5. Seleccionar el color azul.
      await tester.tap(find.byKey(const Key('seed_color_azul')));

      await tester.pumpAndSettle();

      // El panel debe cerrarse después de seleccionar.
      expect(find.text('Personalizar color'), findsNothing);

      // 6. Consultar el estado actualizado de ThemeCubit.
      final pageContext = tester.element(find.byType(WalletHomePage));

      final themeState = pageContext.read<ThemeCubit>().state;

      expect(themeState.seedColor, blue);

      // El cambio de color no debe modificar el modo claro.
      expect(themeState.mode, ThemeMode.light);

      // 7. Verificar el esquema de colores aplicado.
      final appliedScheme = Theme.of(pageContext).colorScheme;

      final expectedScheme = ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.light,
      );

      expect(appliedScheme.primary, expectedScheme.primary);

      expect(appliedScheme.brightness, Brightness.light);

      // 8. Volver a abrir el selector.
      await tester.tap(pickerButton);
      await tester.pumpAndSettle();

      // El azul debe aparecer marcado como seleccionado.
      final blueOption = tester.widget<ListTile>(
        find.byKey(const Key('seed_color_azul')),
      );

      expect(blueOption.selected, isTrue);

      // El granate ya no debe aparecer seleccionado.
      final granateOption = tester.widget<ListTile>(
        find.byKey(const Key('seed_color_granate')),
      );

      expect(granateOption.selected, isFalse);
    });

    // PRUEBA 2: Cambiar de tema conservando el color.
    testWidgets('Conserva el verde al cambiar del modo claro al oscuro', (
      WidgetTester tester,
    ) async {
      // 1. Construir la aplicación en modo claro.
      await tester.pumpWidget(
        const WalletApp(
          firebaseStatus: FirebaseStatus.notConfigured(),
          initialThemeMode: ThemeMode.light,
        ),
      );

      await tester.pumpAndSettle();

      // 2. Abrir el selector.
      await tester.tap(find.byKey(const Key('seed_color_picker_button')));

      await tester.pumpAndSettle();

      // 3. Seleccionar verde.
      await tester.tap(find.byKey(const Key('seed_color_verde')));

      await tester.pumpAndSettle();

      // Verificar el estado inicial después del cambio.
      var pageContext = tester.element(find.byType(WalletHomePage));

      var themeState = pageContext.read<ThemeCubit>().state;

      expect(themeState.seedColor, green);
      expect(themeState.mode, ThemeMode.light);

      // 4. Cambiar al modo oscuro.
      await tester.tap(find.byKey(const Key('theme_cycle_button')));

      await tester.pumpAndSettle();

      // 5. Consultar nuevamente el estado.
      pageContext = tester.element(find.byType(WalletHomePage));

      themeState = pageContext.read<ThemeCubit>().state;

      // Debe conservar el verde.
      expect(themeState.seedColor, green);

      // Ahora debe encontrarse en modo oscuro.
      expect(themeState.mode, ThemeMode.dark);

      // 6. Comprobar el tema oscuro generado.
      final appliedScheme = Theme.of(pageContext).colorScheme;

      final expectedScheme = ColorScheme.fromSeed(
        seedColor: green,
        brightness: Brightness.dark,
      );

      expect(appliedScheme.brightness, Brightness.dark);

      expect(appliedScheme.primary, expectedScheme.primary);

      // 7. Confirmar que la aplicación sigue mostrando
      // el resumen financiero.
      expect(find.byKey(const Key('balance_amount')), findsOneWidget);

      expect(find.text('S/ 1,274.60'), findsOneWidget);

      // 8. Abrir nuevamente el selector.
      await tester.tap(find.byKey(const Key('seed_color_picker_button')));

      await tester.pumpAndSettle();

      // El verde debe continuar seleccionado.
      final greenOption = tester.widget<ListTile>(
        find.byKey(const Key('seed_color_verde')),
      );

      expect(greenOption.selected, isTrue);
    });
  });
}
