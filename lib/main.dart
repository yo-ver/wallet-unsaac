import 'package:flutter/material.dart';

import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_storage.dart';

/// Punto de entrada de Wallet UNSAAC.
///
/// Responsabilidades:
/// 1. Inicializar los servicios de Flutter.
/// 2. Recuperar el tema guardado localmente.
/// 3. Inicializar Firebase.
/// 4. Ejecutar la aplicación con el tema recuperado.
Future<void> main() async {
  // 1. Inicializar Flutter antes de utilizar servicios nativos.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Crear el servicio de almacenamiento del tema.
  final themeStorage = ThemeStorage();

  // 3. Recuperar la preferencia guardada.
  // Si no existe, se utiliza el modo del sistema.
  ThemeMode initialThemeMode;

  try {
    initialThemeMode = await themeStorage.loadThemeMode();
  } catch (error) {
    // Evitar que un fallo de almacenamiento impida abrir la app.
    debugPrint('Error al recuperar el tema: $error');

    initialThemeMode = ThemeMode.system;
  }

  // 4. Inicializar Firebase.
  // Si no está configurado, la aplicación puede usar datos locales.
  final firebaseStatus = await FirebaseBootstrap.initialize();

  // 5. Ejecutar Wallet UNSAAC con el tema recuperado.
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      initialThemeMode: initialThemeMode,
    ),
  );
}
