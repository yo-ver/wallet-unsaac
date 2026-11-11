# Wallet UNSAAC — proyecto base de la Sesión 1

Aplicativo de finanzas personales del curso **Desarrollo de Software II
(IF616AIN)** de la Escuela Profesional de Ingeniería Informática y de Sistemas
de la UNSAAC.

Esta es la versión de la **Sesión 1 (lunes 9 de noviembre de 2026)**: arquitectura
por capas, patrón BLoC con `ThemeCubit`, Material 3 y conexión preparada para
Firebase. Los datos son de demostración y viven en memoria; la autenticación y
Firestore se incorporan en las sesiones 3 y 5.

## Estado verificado

| Verificación | Resultado |
|---|---|
| `flutter --version` | Flutter 3.44.9 · Dart 3.12.2 (canal estable) |
| `flutter analyze` | Sin observaciones |
| `flutter test` | 13 pruebas aprobadas |
| Plataforma | Android (`applicationId` `pe.edu.unsaac.wallet_unsaac`) |

> El proyecto no incluye credenciales reales de Firebase. Mientras
> `lib/firebase_options.dart` conserve los marcadores `REEMPLAZAR_...`, la app
> arranca en **modo local** y muestra el estado «Firebase: no configurado».
> Esto es intencional: permite trabajar la sesión sin depender de una cuenta de
> Firebase y evita subir credenciales al repositorio.

## Requisitos

- Flutter 3.44.9 o superior (canal estable) y Dart 3.12.2 o superior.
- Android Studio con SDK de Android y un emulador con Google Play, o un
  dispositivo físico con depuración USB.
- Git.
- Para conectar Firebase: una cuenta de Google y FlutterFire CLI.

## Puesta en marcha

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

La app abre con datos de demostración: saldo `S/ 1,274.60`, siete movimientos y
un botón en la barra superior para alternar tema claro/oscuro.

### Conectar Firebase (paso de la sesión)

1. Crear el proyecto en <https://console.firebase.google.com/>.
2. Registrar una aplicación **Android** con el `applicationId`
   `pe.edu.unsaac.wallet_unsaac`.
3. Instalar y ejecutar FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Seleccionar el proyecto, la plataforma `android` y confirmar. El comando
   sobrescribe `lib/firebase_options.dart` con las credenciales reales.
5. Volver a ejecutar `flutter run`. La tarjeta inferior debe mostrar
   «Firebase: conectado».

El `applicationId` se cambia en `android/app/build.gradle.kts`. Si se modifica,
hay que registrar de nuevo la app en Firebase Console y repetir
`flutterfire configure`.

## Estructura del proyecto

```text
lib/
├── main.dart                      # ensureInitialized → Firebase → runApp
├── app.dart                       # providers, MaterialApp y tema
├── firebase_options.dart          # plantilla que genera flutterfire configure
├── core/
│   ├── config/
│   │   ├── firebase_bootstrap.dart
│   │   └── firebase_status.dart
│   ├── theme/
│   │   ├── app_theme.dart         # ColorScheme.fromSeed (claro/oscuro)
│   │   ├── theme_cubit.dart       # lógica del tema
│   │   └── theme_state.dart       # estado inmutable con Equatable
│   └── utils/
│       └── money.dart             # formato de soles y fechas
└── features/
    └── wallet/
        ├── domain/
        │   ├── entities/
        │   │   ├── movement.dart
        │   │   └── wallet_summary.dart
        │   └── repositories/
        │       └── wallet_repository.dart
        ├── data/
        │   └── repositories/
        │       └── in_memory_wallet_repository.dart
        └── presentation/
            ├── pages/
            │   └── wallet_home_page.dart
            └── widgets/
                ├── balance_card.dart
                ├── firebase_status_card.dart
                └── movement_tile.dart
```

La regla de dependencia es unidireccional:

```text
presentation → domain ← data
```

- `presentation` conoce `domain`, nunca `data`.
- `data` implementa las interfaces de `domain`.
- `domain` no importa Flutter, Firebase ni HTTP.

El diagrama editable está en [`docs/arquitectura.md`](docs/arquitectura.md).

## Flujo BLoC de la sesión

```text
Usuario pulsa el icono de tema
        │
        ▼
context.read<ThemeCubit>().toggle()      (evento / intención)
        │
        ▼
ThemeCubit.emit(ThemeState(mode: ...))   (nuevo estado inmutable)
        │
        ▼
BlocBuilder<ThemeCubit, ThemeState>       (escucha el stream)
        │
        ▼
MaterialApp(themeMode: state.mode)        (nueva interfaz)
```

`ThemeCubit` es un **Cubit** (no un Bloc con eventos): la intención se expresa
con un método y el estado se emite directamente. En la Sesión 2 se construirá
un Bloc completo con eventos, para contrastar ambos enfoques.

## Decisiones de diseño

1. **Estado inmutable con `Equatable`.** `ThemeState` implementa `props`, de
   modo que BLoC puede comparar estados por valor y evitar reconstrucciones
   innecesarias.
2. **`ThemeMode` en el estado.** Permite claro, oscuro y «seguir al sistema»
   sin añadir banderas redundantes.
3. **Repositorio abstracto.** `WalletRepository` aísla la fuente de datos. En
   la Sesión 5 se reemplaza `InMemoryWalletRepository` por Firestore sin tocar
   la pantalla.
4. **Firebase defensivo.** `FirebaseBootstrap` distingue credenciales ausentes,
   inicialización correcta y error. La app nunca se queda en pantalla blanca.
5. **Permiso de Internet en el manifiesto principal.** La plantilla de Flutter
   solo lo declara en `debug` y `profile`; sin el permiso en `main`, un APK de
   release no puede hablar con Firebase ni con una API REST.
6. **Sin secretos.** El repositorio incluye una plantilla, no credenciales.
   `google-services.json`, `key.properties` y los almacenes de claves están en
   `.gitignore`.

## Pruebas incluidas

| Archivo | Qué verifica |
|---|---|
| `test/theme_cubit_test.dart` | Estado inicial, `toggle`, `setMode`, `useSystemMode`. |
| `test/wallet_summary_test.dart` | Cálculo de ingresos, egresos y saldo en el dominio. |
| `test/money_format_test.dart` | Formato `S/ 1,274.60` y fechas `dd/mm/aaaa`. |
| `test/in_memory_wallet_repository_test.dart` | Totales de los datos de demostración. |
| `test/widget_test.dart` | Saldo visible y cambio de `themeMode` al pulsar el botón. |

## Errores frecuentes

| Síntoma | Causa probable | Solución |
|---|---|---|
| «Firebase: no configurado» | Marcadores `REEMPLAZAR_...` | Ejecutar `flutterfire configure`. |
| `FirebaseException: API key not valid` | `applicationId` distinto al registrado | Registrar la app con el mismo `applicationId` y regenerar opciones. |
| La app funciona en debug pero no en release | Falta `INTERNET` en el manifiesto principal | Verificar `android/app/src/main/AndroidManifest.xml`. |
| `UnsupportedError` de plataforma | Se ejecutó en iOS/escritorio | La plantilla es solo Android (decisión de la unidad). |
| Gradle falla por ruta con acentos | Ruta del proyecto con caracteres no ASCII | Mover el proyecto a una ruta ASCII, por ejemplo `~/dev/wallet_unsaac`. |

> Nota de entorno: en algunos equipos con Flutter 3.44.9, `flutter analyze`
> falla si la ruta del proyecto contiene acentos. Es un problema del servidor de
> análisis, no del código. Para verificarlo, copie el proyecto a una ruta ASCII.

## Referencias

- Bloc Library. (2026). *Bloc library documentation*. https://bloclibrary.dev/
- Google. (2026). *Flutter documentation*. https://docs.flutter.dev/
- Google. (2026). *Firebase documentation*. https://firebase.google.com/docs
- Google. (2026). *Build and release an Android app*. https://docs.flutter.dev/deployment/android
- Jiménez, A. (s. f.). *Curso de Flutter con Firebase*. Platzi. https://platzi.com/cursos/flutter-firebase/

## Licencia y uso académico

Material elaborado para el curso IF616AIN de la UNSAAC. El código puede usarse
libremente con fines académicos; se agradece citar la fuente.
