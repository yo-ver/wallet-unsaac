import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// Representa una opción de color disponible.
class SeedColorOption {
  const SeedColorOption({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Identificador de la opción.
  final String id;

  /// Nombre mostrado al usuario.
  final String name;

  /// Color semilla.
  final Color color;
}

/// Selector de colores para Wallet UNSAAC.
///
/// Permite elegir entre cuatro colores semilla.
/// Utiliza BlocSelector para observar únicamente
/// los cambios de ThemeState.seedColor.
class SeedColorPicker extends StatelessWidget {
  const SeedColorPicker({super.key});

  /// Colores disponibles para personalizar el tema.
  static const List<SeedColorOption> colors = [
    SeedColorOption(
      id: 'granate',
      name: 'Granate institucional',
      color: AppTheme.seed,
    ),
    SeedColorOption(id: 'azul', name: 'Azul', color: Color(0xFF1565C0)),
    SeedColorOption(id: 'verde', name: 'Verde', color: Color(0xFF2E7D32)),
    SeedColorOption(id: 'morado', name: 'Morado', color: Color(0xFF6A1B9A)),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, Color>(
      // Observar únicamente los cambios del color semilla.
      selector: (state) => state.seedColor,

      builder: (context, selectedColor) {
        return SafeArea(
          top: false,

          // Permitir desplazamiento vertical cuando el espacio
          // disponible sea insuficiente para mostrar las opciones.
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Título del selector.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Text(
                      'Personalizar color',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Construir las cuatro opciones disponibles.
                  for (final option in colors)
                    _buildColorOption(
                      context: context,
                      option: option,
                      selectedColor: selectedColor,
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye una opción del selector.
  Widget _buildColorOption({
    required BuildContext context,
    required SeedColorOption option,
    required Color selectedColor,
  }) {
    // Determinar si la opción está seleccionada.
    final isSelected = selectedColor == option.color;

    return ListTile(
      key: Key('seed_color_${option.id}'),

      // Representación visual del color.
      leading: CircleAvatar(
        backgroundColor: option.color,
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),

      // Nombre de la opción.
      title: Text(option.name),

      // Resaltar la opción seleccionada.
      selected: isSelected,

      // Indicador adicional de selección.
      trailing: isSelected ? const Icon(Icons.check_circle_outline) : null,

      // Cambiar el color al seleccionar una opción.
      onTap: () {
        context.read<ThemeCubit>().setSeedColor(option.color);

        // Cerrar el selector después de seleccionar.
        Navigator.of(context).pop();
      },
    );
  }
}
