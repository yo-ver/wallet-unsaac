import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';

/// Cubit encargado de administrar la privacidad
/// de los importes financieros en Wallet UNSAAC.
///
/// No modifica los datos del repositorio.
/// Únicamente controla si deben mostrarse u ocultarse.
class PrivacyCubit extends Cubit<PrivacyState> {
  /// Inicialmente los importes son visibles.
  PrivacyCubit() : super(const PrivacyState());

  /// Oculta los importes financieros.
  void hide() {
    if (state.isHidden) return;

    emit(state.copyWith(isHidden: true));
  }

  /// Muestra los importes financieros.
  void show() {
    if (!state.isHidden) return;

    emit(state.copyWith(isHidden: false));
  }

  /// Alterna entre importes visibles y ocultos.
  void toggle() {
    emit(state.copyWith(isHidden: !state.isHidden));
  }
}
