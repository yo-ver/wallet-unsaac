import 'package:flutter/material.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';

/// Punto de entrada de Wallet UNSAAC.
///
/// Orden obligatorio:
/// 1. `WidgetsFlutterBinding.ensureInitialized()` habilita los canales de
///    plataforma antes de tocar servicios nativos.
/// 2. La inicialización de Firebase se intenta antes de `runApp`, pero nunca
///    bloquea el arranque: si el proyecto aún no tiene credenciales, la app
///    abre en modo local con datos de demostración.
/// 3. `runApp` construye el árbol de widgets.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  runApp(WalletApp(firebaseStatus: firebaseStatus));
}
