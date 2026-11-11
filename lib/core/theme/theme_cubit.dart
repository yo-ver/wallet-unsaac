import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// `Cubit` que gobierna el tema claro/oscuro.
///
/// Un Cubit es un BLoC sin eventos explícitos: la interfaz invoca métodos y el
/// Cubit emite estados. Es la opción recomendada cuando la lógica es simple y
/// no requiere trazabilidad de eventos.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({ThemeMode initialMode = ThemeMode.system})
    : super(ThemeState(mode: initialMode));

  /// Alterna entre claro y oscuro. Si el estado actual es `system`, el primer
  /// toque lleva a oscuro para que el cambio sea perceptible.
  void toggle() {
    emit(state.copyWith(mode: state.isDark ? ThemeMode.light : ThemeMode.dark));
  }

  void setMode(ThemeMode mode) => emit(state.copyWith(mode: mode));

  void useSystemMode() => setMode(ThemeMode.system);
}
