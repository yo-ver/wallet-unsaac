import 'package:firebase_core/firebase_core.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/firebase_options.dart';

/// Inicialización defensiva de Firebase.
///
/// La aplicación debe poder abrirse incluso antes de que el estudiante haya
/// creado su proyecto de Firebase. Por eso se distinguen tres situaciones:
/// - credenciales ausentes  → modo local, sin excepción;
/// - credenciales presentes → inicialización normal;
/// - fallo de inicialización → estado de error visible, sin bloquear la UI.
abstract final class FirebaseBootstrap {
  /// `true` cuando `firebase_options.dart` ya fue generado por FlutterFire.
  static bool get isConfigured {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return options.apiKey.isNotEmpty &&
          !options.apiKey.startsWith('REEMPLAZAR');
    } catch (_) {
      return false;
    }
  }

  static Future<FirebaseStatus> initialize() async {
    if (!isConfigured) {
      return const FirebaseStatus.notConfigured();
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return const FirebaseStatus.ready();
    } on FirebaseException catch (error) {
      return FirebaseStatus.failed('${error.code}: ${error.message}');
    } catch (error) {
      return FirebaseStatus.failed(error.toString());
    }
  }
}
