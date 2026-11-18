import 'package:flutter/material.dart';

/// Configuración visual de Wallet UNSAAC.
///
/// Utiliza Material 3 y ColorScheme.fromSeed para generar
/// paletas de colores adaptadas a los modos claro y oscuro.
///
/// El color semilla puede cambiar dinámicamente mediante ThemeCubit.
abstract final class AppTheme {
  /// Color institucional predeterminado de Wallet UNSAAC.
  static const Color seed = Color(0xFF7A1F2B);

  /// Genera el tema claro a partir del color semilla.
  ///
  /// Si no se proporciona un color, utiliza el granate institucional.
  static ThemeData light({Color seedColor = seed}) {
    return _build(brightness: Brightness.light, seedColor: seedColor);
  }

  /// Genera el tema oscuro a partir del color semilla.
  ///
  /// Si no se proporciona un color, utiliza el granate institucional.
  static ThemeData dark({Color seedColor = seed}) {
    return _build(brightness: Brightness.dark, seedColor: seedColor);
  }

  /// Construye un ThemeData utilizando Material 3.
  ///
  /// ColorScheme.fromSeed genera una paleta de colores
  /// coherente según el color semilla y el brillo seleccionado.
  static ThemeData _build({
    required Brightness brightness,
    required Color seedColor,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,

      // Esquema de colores generado dinámicamente.
      colorScheme: scheme,

      // Color de fondo de la pantalla.
      scaffoldBackgroundColor: scheme.surface,

      // Configuración de la barra superior.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),

      // Configuración de las tarjetas.
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Configuración de los botones principales.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // Configuración de las notificaciones.
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
