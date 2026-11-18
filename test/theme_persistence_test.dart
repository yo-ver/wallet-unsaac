import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_storage.dart';

void main() {
  // Preparar un almacenamiento limpio antes de cada prueba.
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('Reto 1 - Persistencia del tema', () {
    // PRUEBA 1
    test('Sin preferencia guardada inicia en modo sistema', () async {
      final storage = ThemeStorage();

      final mode = await storage.loadThemeMode();

      expect(mode, ThemeMode.system);
    });

    // PRUEBA 2
    test('Guardar y recuperar el modo oscuro', () async {
      final storage = ThemeStorage();

      // Guardar el modo oscuro.
      await storage.saveThemeMode(ThemeMode.dark);

      // Crear otra instancia para simular una nueva lectura.
      final newStorage = ThemeStorage();

      final recoveredMode = await newStorage.loadThemeMode();

      expect(recoveredMode, ThemeMode.dark);
    });

    // PRUEBA 3
    test('Un valor invalido utiliza el modo sistema', () async {
      final preferences = SharedPreferencesAsync();

      // Simular una preferencia corrupta o desconocida.
      await preferences.setString(
        ThemeStorage.themeModeKey,
        'modo_desconocido',
      );

      final storage = ThemeStorage();

      final recoveredMode = await storage.loadThemeMode();

      // La aplicación debe utilizar el modo predeterminado.
      expect(recoveredMode, ThemeMode.system);
    });

    // PRUEBA 4
    test('ThemeCubit guarda el modo seleccionado', () async {
      final storage = ThemeStorage();

      final cubit = ThemeCubit(storage: storage);

      // Cambiar al modo oscuro desde el Cubit.
      await cubit.setMode(ThemeMode.dark);

      // Verificar el estado emitido.
      expect(cubit.state.mode, ThemeMode.dark);

      // Comprobar que el almacenamiento contiene el nuevo modo.
      final savedMode = await storage.loadThemeMode();

      expect(savedMode, ThemeMode.dark);

      // Liberar los recursos del Cubit.
      await cubit.close();
    });
  });
}
