import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';

void main() {
  test('el repositorio en memoria entrega los movimientos de demostración', () async {
    final repository = InMemoryWalletRepository(latency: Duration.zero);

    final summary = await repository.loadSummary();

    expect(summary.movements, hasLength(7));
    expect(summary.income, 1770);
    expect(summary.expenses, 495.40);
    expect(summary.balance, closeTo(1274.60, 0.001));
  });
}
