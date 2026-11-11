import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';

/// Resumen financiero que consume la pantalla principal.
///
/// Los totales se calculan en el dominio, no en la interfaz: así la misma
/// lógica sirve para la pantalla, las pruebas y, más adelante, Firestore.
class WalletSummary {
  const WalletSummary({required this.movements});

  final List<Movement> movements;

  double get income => movements
      .where((movement) => movement.isIncome)
      .fold(0, (total, movement) => total + movement.amount);

  double get expenses => movements
      .where((movement) => !movement.isIncome)
      .fold(0, (total, movement) => total + movement.amount);

  double get balance => income - expenses;

  bool get isEmpty => movements.isEmpty;
}
