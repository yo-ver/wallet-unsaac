import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la persistencia local del modo de tema.
///
/// Esta clase no depende de widgets ni del estado de la interfaz.
/// Su responsabilidad es guardar y recuperar la preferencia del usuario.
class ThemeStorage {
  ThemeStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  /// Servicio de almacenamiento local.
  final SharedPreferencesAsync _preferences;

  /// Clave utilizada para guardar el modo seleccionado.
  static const String themeModeKey = 'wallet_theme_mode';

  /// Recupera el modo de tema previamente guardado.
  ///
  /// Si no existe una preferencia o el valor es desconocido,
  /// se utiliza ThemeMode.system.
  Future<ThemeMode> loadThemeMode() async {
    final savedMode = await _preferences.getString(themeModeKey);

    switch (savedMode) {
      case 'light':
        return ThemeMode.light;

      case 'dark':
        return ThemeMode.dark;

      case 'system':
        return ThemeMode.system;

      default:
        return ThemeMode.system;
    }
  }

  /// Guarda el modo de tema seleccionado.
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _preferences.setString(themeModeKey, mode.name);
  }
}
