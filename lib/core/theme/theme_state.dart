import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Estado inmutable del tema de Wallet UNSAAC.
///
/// Administra:
/// - El modo de visualización: claro, oscuro o sistema.
/// - El color semilla utilizado por Material 3.
///
/// Equatable permite comparar los estados por sus propiedades.
class ThemeState extends Equatable {
  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor = AppTheme.seed,
  });

  /// Modo de visualización seleccionado.
  final ThemeMode mode;

  /// Color semilla utilizado para generar el tema.
  final Color seedColor;

  /// Indica si se seleccionó explícitamente el modo oscuro.
  bool get isDark => mode == ThemeMode.dark;

  /// Genera un nuevo estado conservando los valores
  /// de las propiedades que no se modifican.
  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  /// Propiedades utilizadas para comparar los estados.
  ///
  /// Un cambio de modo o de color produce un estado diferente.
  @override
  List<Object?> get props => [mode, seedColor];
}
