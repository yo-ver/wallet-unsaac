import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Contrato de la capa de datos.
///
/// La presentación y el dominio dependen de esta abstracción, nunca de una
/// implementación concreta. En la Sesión 1 se usa una implementación en
/// memoria; en la Sesión 5 se sustituirá por Firestore sin tocar la interfaz.
abstract interface class WalletRepository {
  Future<WalletSummary> loadSummary();
}
