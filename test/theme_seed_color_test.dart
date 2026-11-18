import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

void main() {
  // Colores utilizados durante las pruebas.
  const blue = Color(0xFF1565C0);
  const green = Color(0xFF2E7D32);

  group('Reto 4 - Color semilla configurable', () {
    // PRUEBA 1: Estado inicial.
    test('ThemeState inicia con el color institucional', () {
      const state = ThemeState();

      expect(state.mode, ThemeMode.system);
      expect(state.seedColor, AppTheme.seed);
    });

    // PRUEBA 2: Igualdad de estados.
    test('Equatable considera el color semilla', () {
      const original = ThemeState(
        mode: ThemeMode.dark,
        seedColor: AppTheme.seed,
      );

      const modified = ThemeState(mode: ThemeMode.dark, seedColor: blue);

      // Aunque el modo sea igual, los colores son distintos.
      expect(original, isNot(equals(modified)));

      // copyWith debe conservar las propiedades no modificadas.
      final updated = original.copyWith(seedColor: blue);

      expect(updated.mode, ThemeMode.dark);
      expect(updated.seedColor, blue);
      expect(updated, modified);
    });

    // PRUEBA 3: Cambio de color.
    blocTest<ThemeCubit, ThemeState>(
      'setSeedColor() emite el color seleccionado',
      build: () => ThemeCubit(),
      act: (cubit) {
        cubit.setSeedColor(blue);
      },
      expect: () => [const ThemeState(mode: ThemeMode.system, seedColor: blue)],
    );

    // PRUEBA 4: Evitar emisiones redundantes.
    blocTest<ThemeCubit, ThemeState>(
      'No emite estados si se selecciona el mismo color',
      build: () => ThemeCubit(),
      act: (cubit) {
        cubit.setSeedColor(blue);
        cubit.setSeedColor(blue);
        cubit.setSeedColor(blue);
      },
      expect: () => [const ThemeState(mode: ThemeMode.system, seedColor: blue)],
    );

    // PRUEBA 5: Conservar el modo oscuro.
    blocTest<ThemeCubit, ThemeState>(
      'Cambiar el color conserva el modo oscuro',
      build: () => ThemeCubit(initialMode: ThemeMode.dark),
      act: (cubit) {
        cubit.setSeedColor(green);
      },
      expect: () => [const ThemeState(mode: ThemeMode.dark, seedColor: green)],
      verify: (cubit) {
        expect(cubit.state.mode, ThemeMode.dark);
        expect(cubit.state.seedColor, green);
      },
    );

    // PRUEBA 6: Generación de temas dinámicos.
    test('AppTheme genera temas claro y oscuro con el color elegido', () {
      // Crear los temas utilizando el color azul.
      final lightTheme = AppTheme.light(seedColor: blue);
      final darkTheme = AppTheme.dark(seedColor: blue);

      // Construir los esquemas esperados de Material 3.
      final expectedLight = ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.light,
      );

      final expectedDark = ColorScheme.fromSeed(
        seedColor: blue,
        brightness: Brightness.dark,
      );

      // Verificar el modo de iluminación.
      expect(lightTheme.colorScheme.brightness, Brightness.light);

      expect(darkTheme.colorScheme.brightness, Brightness.dark);

      // Verificar que ambos temas utilizan
      // los esquemas generados con el color seleccionado.
      expect(lightTheme.colorScheme.primary, expectedLight.primary);

      expect(darkTheme.colorScheme.primary, expectedDark.primary);

      // Los temas deben conservar el uso de Material 3.
      expect(lightTheme.useMaterial3, isTrue);
      expect(darkTheme.useMaterial3, isTrue);
    });
  });
}
