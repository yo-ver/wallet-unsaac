import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/utils/money.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';

/// Fila de un movimiento financiero.
///
/// Permite ocultar el importe sin modificar los datos
/// originales del movimiento.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    this.hideAmount = false,
  });

  /// Movimiento financiero original.
  final Movement movement;

  /// Indica si el importe debe ocultarse.
  final bool hideAmount;

  /// Máscara utilizada cuando se activa la privacidad.
  static const String hiddenAmount = 'S/ ••••••';

  static const Color _incomeLight = Color(0xFF2E7D32);
  static const Color _incomeDark = Color(0xFF81C784);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = movement.isIncome
        ? (isDark ? _incomeDark : _incomeLight)
        : scheme.error;

    // El importe solamente se formatea cuando está visible.
    final amountText = hideAmount
        ? hiddenAmount
        : '${movement.isIncome ? '+' : '-'} '
              '${MoneyFormat.soles(movement.amount)}';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

        // Icono del tipo de movimiento.
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(
            movement.isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: accent,
            size: 20,
          ),
        ),

        // Nombre del movimiento.
        title: Text(
          movement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        // Categoría y fecha.
        subtitle: Text(
          '${movement.category} · '
          '${formatShortDate(movement.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Importe visible u oculto.
        trailing: Text(
          amountText,
          key: Key('movement_amount_${movement.id}'),
          style: TextStyle(color: accent, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
