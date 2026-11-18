import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';

import 'package:wallet_unsaac/core/theme/seed_color_picker.dart';

/// Pantalla principal de Wallet UNSAAC (Sesión 1).
///
/// Muestra el resumen que entrega el repositorio y permite alternar el tema.
/// El cambio de tema lo resuelve `ThemeCubit`; la pantalla solo envía la
/// intención del usuario y se reconstruye cuando el estado cambia.
class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  @override
  void initState() {
    super.initState();

    // Iniciar la carga del resumen financiero mediante el Cubit.
    context.read<BalanceCubit>().loadBalance();
  }

  /// Actualiza el resumen financiero mediante BalanceCubit.
  ///
  /// Se utiliza desde RefreshIndicator.
  Future<void> _reload() async {
    await context.read<BalanceCubit>().refresh();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature se habilita en la Sesión 2.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wallet UNSAAC',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // Botón para personalizar el color de Wallet UNSAAC.
          IconButton(
            key: const Key('seed_color_picker_button'),

            tooltip: 'Personalizar colores',

            icon: const Icon(Icons.palette_outlined),

            onPressed: () {
              // Obtener la instancia actual de ThemeCubit.
              final themeCubit = context.read<ThemeCubit>();

              // Abrir el selector en un panel inferior.
              showModalBottomSheet<void>(
                context: context,

                // Permitir que el panel utilice más espacio vertical.
                isScrollControlled: true,

                showDragHandle: true,

                builder: (bottomSheetContext) {
                  return BlocProvider.value(
                    value: themeCubit,
                    child: const SeedColorPicker(),
                  );
                },
              );
            },
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              // Obtener el modo de tema actual.
              final mode = state.mode;

              // Seleccionar el icono según el modo actual.
              final IconData icon;

              // Texto accesible que describe el modo y la siguiente acción.
              final String tooltip;

              switch (mode) {
                case ThemeMode.light:
                  icon = Icons.light_mode_outlined;
                  tooltip = 'Tema claro. Cambiar a oscuro';
                  break;

                case ThemeMode.dark:
                  icon = Icons.dark_mode_outlined;
                  tooltip = 'Tema oscuro. Cambiar a sistema';
                  break;

                case ThemeMode.system:
                  icon = Icons.brightness_auto_outlined;
                  tooltip = 'Tema del sistema. Cambiar a claro';
                  break;
              }

              return IconButton(
                key: const Key('theme_cycle_button'),
                tooltip: tooltip,
                icon: Icon(icon),

                // Cambiar al siguiente modo y guardar la preferencia.
                onPressed: () {
                  context.read<ThemeCubit>().cycleMode();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<BalanceCubit, BalanceState>(
        builder: (context, balanceState) {
          // ESTADO INICIAL Y DE CARGA
          if (balanceState is BalanceInitial ||
              balanceState is BalanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ESTADO DE ERROR
          if (balanceState is BalanceFailure) {
            return _ErrorView(
              message: balanceState.message,

              // Reintentar la consulta mediante el Cubit.
              onRetry: () {
                return context.read<BalanceCubit>().retry();
              },
            );
          }

          // ESTADO DE ÉXITO
          final summary = (balanceState as BalanceSuccess).summary;

          // Mostrar el resumen financiero y permitir actualizarlo.
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  'Hola, estudiante UNSAAC',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este es el resumen de tus finanzas en noviembre de 2026.',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                // Reconstruir la tarjeta cuando cambia la privacidad.
                BlocBuilder<PrivacyCubit, PrivacyState>(
                  builder: (context, privacyState) {
                    return BalanceCard(
                      summary: summary,

                      // Indicar si los importes deben ocultarse.
                      hideBalance: privacyState.isHidden,

                      // Cambiar la privacidad al pulsar el botón del ojo.
                      onToggleVisibility: () {
                        context.read<PrivacyCubit>().toggle();
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _showComingSoon('Registrar ingreso'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Ingreso'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showComingSoon('Registrar egreso'),
                        icon: const Icon(Icons.remove_rounded),
                        label: const Text('Egreso'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Últimos movimientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showComingSoon('El historial completo'),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (summary.isEmpty)
                  const _EmptyMovements()
                else
                  for (final movement in summary.movements) ...[
                    // Escuchar los cambios de privacidad.
                    BlocBuilder<PrivacyCubit, PrivacyState>(
                      builder: (context, privacyState) {
                        return MovementTile(
                          movement: movement,

                          // Ocultar o mostrar el importe según el estado.
                          hideAmount: privacyState.isHidden,
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 12),
                FirebaseStatusCard(status: widget.firebaseStatus),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Datos de demostración · Wallet UNSAAC 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa la conexión y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no registraste movimientos.'),
          ],
        ),
      ),
    );
  }
}
