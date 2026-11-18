import 'package:equatable/equatable.dart';

import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Estado base de la consulta del saldo.
///
/// Se utiliza una clase sealed para restringir los estados
/// posibles de la consulta financiera.
sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
///
/// Representa el momento anterior a la primera consulta.
final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

/// Estado de carga.
///
/// Se emite mientras el repositorio consulta los datos.
final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

/// Estado de éxito.
///
/// Contiene el resumen financiero recuperado del repositorio.
final class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  /// Resumen financiero obtenido correctamente.
  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// Estado de error.
///
/// Contiene un mensaje que puede mostrarse al usuario.
final class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  /// Descripción comprensible del problema.
  final String message;

  @override
  List<Object?> get props => [message];
}
