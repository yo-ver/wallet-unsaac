import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

void main() {
  group('ThemeCubit', () {
    test('inicia en modo sistema por defecto', () {
      expect(ThemeCubit().state.mode, ThemeMode.system);
    });

    test('acepta un modo inicial explícito', () {
      expect(
        ThemeCubit(initialMode: ThemeMode.dark).state.mode,
        ThemeMode.dark,
      );
    });

    blocTest<ThemeCubit, ThemeState>(
      'toggle alterna de oscuro a claro y viceversa',
      build: ThemeCubit.new,
      act: (cubit) {
        cubit.toggle();
        cubit.toggle();
      },
      expect: () => const [
        ThemeState(mode: ThemeMode.dark),
        ThemeState(mode: ThemeMode.light),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'setMode emite el modo solicitado',
      build: ThemeCubit.new,
      act: (cubit) => cubit.setMode(ThemeMode.light),
      expect: () => const [ThemeState(mode: ThemeMode.light)],
    );

    blocTest<ThemeCubit, ThemeState>(
      'useSystemMode vuelve a seguir la preferencia del dispositivo',
      build: () => ThemeCubit(initialMode: ThemeMode.dark),
      act: (cubit) => cubit.useSystemMode(),
      expect: () => const [ThemeState(mode: ThemeMode.system)],
    );
  });
}
