import 'package:equatable/equatable.dart';

/// Representa el estado de privacidad de Wallet UNSAAC.
///
/// Es inmutable y permite controlar si los importes
/// financieros deben mostrarse u ocultarse.
class PrivacyState extends Equatable {
  /// Por defecto, los importes son visibles.
  const PrivacyState({this.isHidden = false});

  /// Indica si los importes están ocultos.
  final bool isHidden;

  /// Crea un nuevo estado sin modificar el anterior.
  PrivacyState copyWith({bool? isHidden}) {
    return PrivacyState(isHidden: isHidden ?? this.isHidden);
  }

  /// Equatable compara los estados según sus propiedades.
  @override
  List<Object?> get props => [isHidden];
}
