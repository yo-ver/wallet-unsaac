/// Tipo de movimiento financiero.
enum MovementType { income, expense }

/// Movimiento individual de la billetera.
///
/// `amount` siempre es positivo; el signo se deriva del [type]. Esta decisión
/// evita inconsistencias al sumar y simplifica el cálculo del saldo.
class Movement {
  const Movement({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final MovementType type;
  final DateTime date;

  bool get isIncome => type == MovementType.income;

  double get signedAmount => isIncome ? amount : -amount;
}
