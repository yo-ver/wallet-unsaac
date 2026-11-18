import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

void main() {
  group('Reto 2 - Pruebas de widgets de privacidad', () {
    testWidgets('El botón de privacidad oculta y restaura los importes', (
      WidgetTester tester,
    ) async {
      // 1. Construir Wallet UNSAAC.
      await tester.pumpWidget(
        const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
      );

      // Esperar a que se carguen los datos de demostración.
      await tester.pumpAndSettle();

      // Localizar el botón de privacidad.
      final privacyButton = find.byKey(const Key('privacy_toggle_button'));

      // Localizar el texto del saldo principal.
      final balanceAmount = find.byKey(const Key('balance_amount'));

      // 2. VERIFICAR ESTADO INICIAL.

      expect(privacyButton, findsOneWidget);

      expect(tester.widget<Text>(balanceAmount).data, 'S/ 1,274.60');

      expect(find.byTooltip('Ocultar saldo'), findsOneWidget);

      // 3. ACTIVAR MODO PRIVADO.

      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      // El saldo debe quedar oculto.
      expect(tester.widget<Text>(balanceAmount).data, 'S/ ••••••');

      // Los ingresos y egresos originales no deben mostrarse.
      expect(find.text('S/ 1,770.00'), findsNothing);

      expect(find.text('S/ 495.40'), findsNothing);

      // El tooltip debe cambiar.
      expect(find.byTooltip('Mostrar saldo'), findsOneWidget);

      // 4. VERIFICAR PRIVACIDAD DE LOS MOVIMIENTOS.

      final movementTiles = find.byType(MovementTile);

      expect(movementTiles, findsWidgets);

      // Seleccionar el primer movimiento construido.
      final firstMovement = tester.widget<MovementTile>(movementTiles.first);

      // El widget debe recibir el estado de privacidad.
      expect(firstMovement.hideAmount, isTrue);

      // Comprobar que el importe se encuentra enmascarado.
      final movementAmount = find.byKey(
        Key('movement_amount_${firstMovement.movement.id}'),
      );

      expect(tester.widget<Text>(movementAmount).data, 'S/ ••••••');

      // 5. DESACTIVAR MODO PRIVADO.

      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      // Recuperar el saldo original.
      expect(tester.widget<Text>(balanceAmount).data, 'S/ 1,274.60');

      // Recuperar los totales originales.
      expect(find.text('S/ 1,770.00'), findsOneWidget);

      expect(find.text('S/ 495.40'), findsOneWidget);

      // Verificar que los movimientos vuelven a ser visibles.
      final restoredMovement = tester.widget<MovementTile>(
        find.byType(MovementTile).first,
      );

      expect(restoredMovement.hideAmount, isFalse);

      // El tooltip vuelve al estado inicial.
      expect(find.byTooltip('Ocultar saldo'), findsOneWidget);
    });
  });
}
