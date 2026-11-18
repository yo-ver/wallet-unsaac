import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

/// Cubit encargado de administrar la consulta del saldo.
///
/// Controla los estados de carga, éxito y error.
/// La pantalla no necesita comunicarse directamente
/// con WalletRepository.
class BalanceCubit extends Cubit<BalanceState> {
  /// Repositorio utilizado para consultar los datos financieros.
  final WalletRepository _repository;

  /// Inicializa el Cubit en BalanceInitial.
  BalanceCubit(this._repository) : super(const BalanceInitial());

  /// Consulta el resumen financiero.
  ///
  /// Emite:
  /// BalanceLoading -> BalanceSuccess
  ///
  /// Si ocurre un error:
  /// BalanceLoading -> BalanceFailure
  Future<void> loadBalance() async {
    // Evitar operaciones cuando el Cubit está cerrado.
    if (isClosed) return;

    // Indicar que comenzó la consulta.
    emit(const BalanceLoading());

    try {
      // Solicitar los datos al repositorio.
      final summary = await _repository.loadSummary();

      // La consulta es asíncrona.
      // El Cubit podría haberse cerrado mientras esperaba.
      if (isClosed) return;

      // Emitir el resumen recuperado correctamente.
      emit(BalanceSuccess(summary));
    } catch (_) {
      // Evitar emitir errores después del cierre.
      if (isClosed) return;

      // Informar que ocurrió un problema.
      emit(
        const BalanceFailure('No se pudo cargar el resumen de la billetera.'),
      );
    }
  }

  /// Reintenta la consulta después de un error.
  ///
  /// Vuelve a llamar al repositorio y muestra
  /// nuevamente el estado de carga.
  Future<void> retry() async {
    await loadBalance();
  }

  /// Actualiza el resumen financiero.
  ///
  /// Este método será utilizado por RefreshIndicator.
  Future<void> refresh() async {
    await loadBalance();
  }
}
