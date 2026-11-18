import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';

void main() {
  group('Reto 2 - PrivacyCubit', () {
    // PRUEBA 1: Estado inicial.
    test('Inicia con los importes visibles', () async {
      final cubit = PrivacyCubit();

      // El estado inicial debe permitir mostrar los importes.
      expect(cubit.state.isHidden, false);

      await cubit.close();
    });

    // PRUEBA 2: Ocultar importes.
    blocTest<PrivacyCubit, PrivacyState>(
      'hide() oculta los importes',
      build: () => PrivacyCubit(),

      act: (cubit) => cubit.hide(),

      expect: () => [const PrivacyState(isHidden: true)],
    );

    // PRUEBA 3: Mostrar importes.
    blocTest<PrivacyCubit, PrivacyState>(
      'show() restaura la visibilidad',
      build: () => PrivacyCubit(),

      act: (cubit) {
        // Primero ocultar.
        cubit.hide();

        // Después mostrar.
        cubit.show();
      },

      expect: () => [
        const PrivacyState(isHidden: true),
        const PrivacyState(isHidden: false),
      ],
    );

    // PRUEBA 4: Alternar privacidad.
    blocTest<PrivacyCubit, PrivacyState>(
      'toggle() alterna entre visible y oculto',
      build: () => PrivacyCubit(),

      act: (cubit) {
        // Primer cambio: ocultar.
        cubit.toggle();

        // Segundo cambio: mostrar.
        cubit.toggle();

        // Tercer cambio: ocultar.
        cubit.toggle();
      },

      expect: () => [
        const PrivacyState(isHidden: true),
        const PrivacyState(isHidden: false),
        const PrivacyState(isHidden: true),
      ],
    );

    // PRUEBA 5: Evitar emisiones redundantes.
    blocTest<PrivacyCubit, PrivacyState>(
      'hide() no emite estados redundantes',
      build: () => PrivacyCubit(),

      act: (cubit) {
        cubit.hide();
        cubit.hide();
        cubit.hide();
      },

      // Solo debe emitirse un estado.
      expect: () => [const PrivacyState(isHidden: true)],
    );
  });
}
