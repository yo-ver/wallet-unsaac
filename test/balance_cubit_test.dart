import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

/// Repositorio falso para probar BalanceCubit.
///
/// Permite simular consultas exitosas y fallidas
/// sin modificar el repositorio original de la aplicación.
class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository({
    required this.summary,
    this.failFirstCall = false,
    this.alwaysFail = false,
  });

  final WalletSummary summary;

  /// Si es verdadero, falla únicamente la primera consulta.
  final bool failFirstCall;

  /// Si es verdadero, todas las consultas fallan.
  final bool alwaysFail;

  /// Número de veces que se consultó el repositorio.
  int callCount = 0;

  @override
  Future<WalletSummary> loadSummary() async {
    callCount++;

    // Simular un error controlado.
    if (alwaysFail || (failFirstCall && callCount == 1)) {
      throw Exception('Error simulado del repositorio');
    }

    // Devolver el resumen financiero de prueba.
    return summary;
  }
}

void main() {
  group('Reto 3 - BalanceCubit', () {
    // Datos de prueba independientes de la aplicación.
    final summary = WalletSummary(movements: const []);

    // PRUEBA 1: Estado inicial.
    test('Inicia en BalanceInitial', () async {
      final repository = FakeWalletRepository(summary: summary);

      final cubit = BalanceCubit(repository);

      expect(cubit.state, const BalanceInitial());

      // El repositorio no debe consultarse automáticamente.
      expect(repository.callCount, 0);

      await cubit.close();
    });

    // PRUEBA 2: Consulta exitosa.
    final successRepository = FakeWalletRepository(summary: summary);

    blocTest<BalanceCubit, BalanceState>(
      'loadBalance() emite Loading y Success',
      build: () => BalanceCubit(successRepository),

      act: (cubit) async {
        await cubit.loadBalance();
      },

      expect: () => [const BalanceLoading(), BalanceSuccess(summary)],

      verify: (_) {
        expect(successRepository.callCount, 1);
      },
    );

    // PRUEBA 3: Consulta fallida.
    final failureRepository = FakeWalletRepository(
      summary: summary,
      alwaysFail: true,
    );

    blocTest<BalanceCubit, BalanceState>(
      'loadBalance() emite Loading y Failure',
      build: () => BalanceCubit(failureRepository),

      act: (cubit) async {
        await cubit.loadBalance();
      },

      expect: () => [
        const BalanceLoading(),
        const BalanceFailure('No se pudo cargar el resumen de la billetera.'),
      ],

      verify: (_) {
        expect(failureRepository.callCount, 1);
      },
    );

    // PRUEBA 4: Recuperación después de un error.
    final retryRepository = FakeWalletRepository(
      summary: summary,
      failFirstCall: true,
    );

    blocTest<BalanceCubit, BalanceState>(
      'retry() permite recuperarse de un error',
      build: () => BalanceCubit(retryRepository),

      act: (cubit) async {
        // Primera consulta: falla.
        await cubit.loadBalance();

        // Segunda consulta: funciona correctamente.
        await cubit.retry();
      },

      expect: () => [
        const BalanceLoading(),
        const BalanceFailure('No se pudo cargar el resumen de la billetera.'),
        const BalanceLoading(),
        BalanceSuccess(summary),
      ],

      verify: (_) {
        // El repositorio debe haberse consultado dos veces.
        expect(retryRepository.callCount, 2);
      },
    );

    // PRUEBA 5: Actualización del resumen.
    final refreshRepository = FakeWalletRepository(summary: summary);

    blocTest<BalanceCubit, BalanceState>(
      'refresh() vuelve a consultar el repositorio',
      build: () => BalanceCubit(refreshRepository),

      act: (cubit) async {
        // Primera carga.
        await cubit.loadBalance();

        // Actualizar el resumen.
        await cubit.refresh();
      },

      expect: () => [
        const BalanceLoading(),
        BalanceSuccess(summary),
        const BalanceLoading(),
        BalanceSuccess(summary),
      ],

      verify: (_) {
        expect(refreshRepository.callCount, 2);
      },
    );
  });
}
