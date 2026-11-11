import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

void main() {
  group('WalletSummary', () {
    final movements = <Movement>[
      Movement(
        id: '1',
        title: 'Ingreso',
        category: 'Trabajo',
        amount: 1000,
        type: MovementType.income,
        date: DateTime(2026, 11, 1),
      ),
      Movement(
        id: '2',
        title: 'Egreso',
        category: 'Transporte',
        amount: 250.50,
        type: MovementType.expense,
        date: DateTime(2026, 11, 2),
      ),
    ];

    test('calcula ingresos, egresos y saldo en el dominio', () {
      final summary = WalletSummary(movements: movements);

      expect(summary.income, 1000);
      expect(summary.expenses, 250.50);
      expect(summary.balance, 749.50);
      expect(summary.isEmpty, isFalse);
    });

    test('un resumen vacío tiene saldo cero', () {
      const summary = WalletSummary(movements: []);

      expect(summary.balance, 0);
      expect(summary.isEmpty, isTrue);
    });
  });
}
