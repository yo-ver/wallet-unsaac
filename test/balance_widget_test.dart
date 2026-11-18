import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';

import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';

/// Repositorio que permite controlar cuándo termina la consulta.
///
/// Se utiliza para comprobar que el indicador de carga
/// permanece visible mientras esperamos los datos.
class DeferredWalletRepository implements WalletRepository {
  final Completer<WalletSummary> completer = Completer<WalletSummary>();

  @override
  Future<WalletSummary> loadSummary() {
    return completer.future;
  }
}

/// Repositorio que falla en la primera consulta
/// y funciona correctamente en la segunda.
class RetryWalletRepository implements WalletRepository {
  int callCount = 0;

  @override
  Future<WalletSummary> loadSummary() async {
    callCount++;

    if (callCount == 1) {
      throw Exception('Error simulado');
    }

    return WalletSummary(movements: const []);
  }
}

/// Repositorio de prueba que registra cuántas veces
/// se solicita el resumen financiero.
///
/// Utiliza los datos de demostración originales.
class CountingWalletRepository implements WalletRepository {
  final InMemoryWalletRepository _delegate = InMemoryWalletRepository(
    latency: Duration.zero,
  );

  /// Número de consultas realizadas.
  int callCount = 0;

  @override
  Future<WalletSummary> loadSummary() {
    callCount++;

    return _delegate.loadSummary();
  }
}

/// Construye la pantalla principal con los Cubits necesarios.
///
/// Permite sustituir el repositorio real por uno de prueba.
Future<void> pumpTestWallet(
  WidgetTester tester,
  WalletRepository repository,
) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<PrivacyCubit>(create: (_) => PrivacyCubit()),
        BlocProvider<BalanceCubit>(create: (_) => BalanceCubit(repository)),
      ],
      child: const MaterialApp(
        home: WalletHomePage(firebaseStatus: FirebaseStatus.notConfigured()),
      ),
    ),
  );
}

void main() {
  group('Reto 3 - Pruebas de widgets', () {
    // PRUEBA 1: Estado de carga y éxito.
    testWidgets('Muestra Loading y después Success', (
      WidgetTester tester,
    ) async {
      final repository = DeferredWalletRepository();

      // Construir la pantalla.
      await pumpTestWallet(tester, repository);

      // Permitir que Flutter procese el estado de carga.
      await tester.pump();

      // Mientras el repositorio no responda,
      // debe mostrarse el indicador de progreso.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simular la respuesta exitosa del repositorio.
      repository.completer.complete(WalletSummary(movements: const []));

      await tester.pumpAndSettle();

      // Verificar que la pantalla muestra el saldo.
      final balanceAmount = find.byKey(const Key('balance_amount'));

      expect(balanceAmount, findsOneWidget);

      // Como no hay movimientos, el saldo es cero.
      expect(tester.widget<Text>(balanceAmount).data, 'S/ 0.00');

      // El indicador central de carga ya no debe aparecer.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // PRUEBA 2: Estado de error y reintento.
    testWidgets('Muestra Failure y permite reintentar', (
      WidgetTester tester,
    ) async {
      final repository = RetryWalletRepository();

      // La pantalla inicia la primera consulta automáticamente.
      await pumpTestWallet(tester, repository);

      await tester.pumpAndSettle();

      // La primera consulta falla.
      expect(repository.callCount, 1);

      // Debe mostrarse el mensaje de error.
      expect(
        find.text('No se pudo cargar el resumen de la billetera.'),
        findsOneWidget,
      );

      // Debe aparecer el botón para reintentar.
      final retryButton = find.text('Reintentar');

      expect(retryButton, findsOneWidget);

      // Simular que el usuario presiona Reintentar.
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // El repositorio debe consultarse nuevamente.
      expect(repository.callCount, 2);

      // La segunda consulta funciona.
      final balanceAmount = find.byKey(const Key('balance_amount'));

      expect(balanceAmount, findsOneWidget);

      expect(tester.widget<Text>(balanceAmount).data, 'S/ 0.00');

      // La pantalla de error desaparece.
      expect(
        find.text('No se pudo cargar el resumen de la billetera.'),
        findsNothing,
      );
    });

    // PRUEBA 3: Actualización mediante RefreshIndicator.
    testWidgets('Deslizar hacia abajo vuelve a consultar el repositorio', (
      WidgetTester tester,
    ) async {
      final repository = CountingWalletRepository();

      // 1. Construir la pantalla con el repositorio de prueba.
      await pumpTestWallet(tester, repository);

      // Esperar a que finalice la carga inicial.
      await tester.pumpAndSettle();

      // 2. Verificar que se realizó una sola consulta inicial.
      expect(repository.callCount, 1);

      // Comprobar que el saldo inicial es correcto.
      final balanceAmount = find.byKey(const Key('balance_amount'));

      expect(tester.widget<Text>(balanceAmount).data, 'S/ 1,274.60');

      // 3. Localizar la lista desplazable.
      final scrollable = find.byType(Scrollable).first;

      // Simular el gesto de deslizar hacia abajo
      // para activar RefreshIndicator.
      await tester.drag(scrollable, const Offset(0, 500));

      // Procesar el gesto y esperar a que termine la actualización.
      await tester.pumpAndSettle();

      // 4. Verificar que el repositorio fue consultado otra vez.
      expect(repository.callCount, 2);

      // 5. Comprobar que la pantalla recuperó el saldo.
      expect(balanceAmount, findsOneWidget);

      expect(tester.widget<Text>(balanceAmount).data, 'S/ 1,274.60');

      // Confirmar que la pantalla de error no está visible.
      expect(
        find.text('No se pudo cargar el resumen de la billetera.'),
        findsNothing,
      );
    });
  });
}
