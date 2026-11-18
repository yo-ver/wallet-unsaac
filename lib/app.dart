import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';

/// Widget principal de Wallet UNSAAC.
///
/// Configura los repositorios, el estado global del tema
/// y la interfaz principal de la aplicación.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    this.initialThemeMode = ThemeMode.system,
  });

  /// Estado de conexión con Firebase.
  final FirebaseStatus firebaseStatus;

  /// Modo de tema recuperado al iniciar la aplicación.
  ///
  /// Si no se proporciona, se utiliza ThemeMode.system.
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WalletRepository>(
          create: (_) => InMemoryWalletRepository(),
        ),
      ],

      child: BlocProvider<ThemeCubit>(
        // Inicializar el Cubit con el tema recibido.
        create: (_) => ThemeCubit(initialMode: initialThemeMode),

        // Reconstruir MaterialApp cuando cambia el tema.
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Wallet UNSAAC',

              debugShowCheckedModeBanner: false,

              // Generar dinámicamente el tema claro
              // utilizando el color seleccionado por el usuario.
              theme: AppTheme.light(seedColor: themeState.seedColor),

              // Generar dinámicamente el tema oscuro
              // utilizando el mismo color semilla.
              darkTheme: AppTheme.dark(seedColor: themeState.seedColor),

              // Mantener el modo claro, oscuro o sistema.
              themeMode: themeState.mode,

              // Pantalla principal.
              home: MultiBlocProvider(
                providers: [
                  // Cubit encargado de la privacidad financiera.
                  BlocProvider<PrivacyCubit>(create: (_) => PrivacyCubit()),

                  // Cubit encargado de consultar el saldo.
                  BlocProvider<BalanceCubit>(
                    create: (context) =>
                        BalanceCubit(context.read<WalletRepository>()),
                  ),
                ],

                // Pantalla principal de Wallet UNSAAC.
                child: WalletHomePage(firebaseStatus: firebaseStatus),
              ),
            );
          },
        ),
      ),
    );
  }
}
