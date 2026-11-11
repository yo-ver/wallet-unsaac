import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Estado del tema de la aplicación.
///
/// Es inmutable: cada cambio produce una instancia nueva mediante
/// `copyWith`. `Equatable` compara por valor, así que dos estados con el mismo
/// `mode` son iguales y BLoC puede omitir emisiones redundantes.
class ThemeState extends Equatable {
  const ThemeState({this.mode = ThemeMode.system});

  final ThemeMode mode;

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? mode}) => ThemeState(mode: mode ?? this.mode);

  @override
  List<Object?> get props => [mode];
}
