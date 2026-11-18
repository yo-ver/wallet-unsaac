import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/core/theme/theme_storage.dart';

/// Cubit encargado de administrar el tema de Wallet UNSAAC.
///
/// Permite cambiar entre los modos claro, oscuro y sistema.
/// Cada cambio se guarda mediante ThemeStorage.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({ThemeMode initialMode = ThemeMode.system, ThemeStorage? storage})
    : _storage = storage ?? ThemeStorage(),
      super(ThemeState(mode: initialMode));

  /// Servicio responsable de almacenar las preferencias.
  final ThemeStorage _storage;

  /// Conserva el comportamiento original del proyecto.
  ///
  /// Si estamos en modo oscuro, cambia a claro.
  /// En cualquier otro caso, cambia a oscuro.
  Future<void> toggle() async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;

    await setMode(newMode);
  }

  /// Cambia el tema y guarda la nueva preferencia.
  Future<void> setMode(ThemeMode mode) async {
    // Evitar cambios innecesarios.
    if (state.mode == mode) return;

    // Actualizar inmediatamente la interfaz.
    emit(state.copyWith(mode: mode));

    // Guardar la preferencia localmente.
    await _storage.saveThemeMode(mode);
  }

  /// Cambia el color semilla de Wallet UNSAAC.
  ///
  /// Actualiza únicamente el color y conserva el modo
  /// claro, oscuro o sistema que tenga seleccionado el usuario.
  void setSeedColor(Color color) {
    // Evitar emisiones innecesarias si el color no cambia.
    if (state.seedColor == color) return;

    // Emitir un nuevo estado con el color seleccionado.
    emit(state.copyWith(seedColor: color));
  }

  /// Establece el tema automático del sistema.
  Future<void> useSystemMode() async {
    await setMode(ThemeMode.system);
  }

  /// Recorre los tres modos del tema:
  ///
  /// Claro → Oscuro → Sistema → Claro.
  Future<void> cycleMode() async {
    final ThemeMode nextMode;

    switch (state.mode) {
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;

      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;

      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
    }

    await setMode(nextMode);
  }
}
