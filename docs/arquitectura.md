# Arquitectura de Wallet UNSAAC — Sesión 1

## Diagrama de capas

```mermaid
flowchart TB
    subgraph P["Presentación (Flutter)"]
        UI["WalletHomePage<br/>BalanceCard · MovementTile"]
        BB["BlocBuilder / BlocProvider"]
    end
    subgraph D["Dominio (Dart puro)"]
        TS["ThemeState"]
        TC["ThemeCubit"]
        WS["WalletSummary · Movement"]
        WR["WalletRepository (contrato)"]
    end
    subgraph DAT["Datos"]
        IMR["InMemoryWalletRepository"]
        FB["FirebaseBootstrap → firebase_core"]
    end
    UI --> BB
    BB -->|"lee estado"| TC
    UI -->|"toggle()"| TC
    TC --> TS
    UI -->|"loadSummary()"| WR
    WR -.->|"implementa"| IMR
    FB -.->|"credenciales"| IMR
```

## Regla de dependencia

```text
presentation  →  domain  ←  data
```

- `presentation` importa entidades, contratos de repositorio y estados.
- `data` implementa los contratos y depende de infraestructura (memoria,
  Firebase, HTTP).
- `domain` no importa `flutter/material.dart`, `firebase_core` ni `http`.

## Flujo del tema

```mermaid
sequenceDiagram
    participant U as Usuario
    participant W as WalletHomePage
    participant C as ThemeCubit
    participant B as BlocBuilder
    participant M as MaterialApp

    U->>W: pulsa icono de tema
    W->>C: toggle()
    C-->>C: emit(ThemeState(mode: dark))
    C-->>B: stream de estados
    B->>M: reconstruye con themeMode = dark
    M-->>U: interfaz en modo oscuro
```

## Estructura por funcionalidad

```text
features/
└── wallet/
    ├── domain/        # entidades y contratos
    ├── data/          # implementaciones (memoria, Firestore)
    └── presentation/  # páginas y widgets
```

Cuando la unidad avance, se agregarán `features/auth/` y
`features/transactions/` con la misma forma. La estructura no cambia: cambia el
contenido de cada capa.
