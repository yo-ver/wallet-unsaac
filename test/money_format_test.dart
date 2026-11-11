import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/core/utils/money.dart';

void main() {
  group('MoneyFormat', () {
    test('formatea importes con separador de miles y dos decimales', () {
      expect(MoneyFormat.soles(0), 'S/ 0.00');
      expect(MoneyFormat.soles(7.5), 'S/ 7.50');
      expect(MoneyFormat.soles(1274.6), 'S/ 1,274.60');
      expect(MoneyFormat.soles(1234567.891), 'S/ 1,234,567.89');
    });

    test('conserva el signo negativo', () {
      expect(MoneyFormat.soles(-250.5), '-S/ 250.50');
    });
  });

  group('formatShortDate', () {
    test('usa el formato dd/mm/aaaa', () {
      expect(formatShortDate(DateTime(2026, 11, 9)), '09/11/2026');
    });
  });
}
