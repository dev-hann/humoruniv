# Architecture

Clean Architecture with three layers. The core principle: **source code dependencies only point inward**.

## Layers

```
┌─────────────────────────────────────┐
│  Presentation                       │
│  Screens, Widgets, Riverpod         │
│  Providers                          │
├──────────────┬──────────────────────┤
│  Domain      │                      │
│  Entities,   │  ← no external deps │
│  Repository  │                      │
│  interfaces, │                      │
│  UseCases    │                      │
├──────────────┴──────────────────────┤
│  Data                               │
│  RepositoryImpls, Api, Parsers,     │
│  DataSources, DTOs                  │
└─────────────────────────────────────┘
```

### Domain Layer

- Pure Dart only. No Flutter, no external packages.
- Contains: entities, repository interfaces (abstract classes), use cases.
- Entities are simple immutable data classes.
- Repository interfaces define what the app needs, not how to get it.
- Use cases encapsulate single business operations.

### Data Layer

- Implements Domain repository interfaces.
- Contains: DTOs, API service, HTML parsers, remote data source.
- `HumorunivRemoteDsImpl` fetches HTML via `HtmlClient`, passes it to the appropriate parser, and returns DTOs.
- DTOs convert to Domain entities via `toEntity()`.
- Parsers are stateless classes with static methods: `String html` -> `Dto`.

### Presentation Layer

- Contains: screens, widgets, Riverpod providers.
- Providers call use cases. They never call repositories or API directly.
- Screens consume providers and render UI.
- Widgets are reusable UI components.

## Dependency Flow

```
Screen
  → Provider
    → UseCase
      → Repository (interface from Domain)
        → RepositoryImpl (from Data)
          → HumorunivRemoteDsImpl
            → HtmlClientImpl (HTTP + EUC-KR decode)
            → MainPageParser (HTML → DTO)
```

## Dependency Injection

All dependencies are registered in `di/injection.dart` using GetIt.

Rules:
- Register interfaces mapped to implementations.
- Singletons for stateless services (API, parsers, data sources).
- Factories for use cases if they hold state.

## Error Handling

Errors propagate from Data to Presentation using `Either<Failure, T>` from dartz.

- Data layer catches exceptions and returns `Left(Failure)`.
- Domain layer passes Either through without modification.
- Presentation layer uses `.fold()` or `.when()` to handle states.

Failure types (see CONVENTIONS.md for naming rules):
- `ServerFailure` - HTTP errors, non-200 responses
- `NetworkFailure` - connectivity issues
- `ParseFailure` - HTML parsing errors, missing expected elements
- `AuthFailure` - login/session errors

## Data Source: HTML Parsing

This app has no REST API. The Data layer fetches HTML pages from `m.humoruniv.com` and parses them.

- `HtmlClientImpl` handles HTTP requests and EUC-KR to UTF-8 decoding.
- Parsers (e.g., `MainPageParser`) convert the decoded HTML string into typed DTOs.
- `HumorunivRemoteDsImpl` orchestrates: fetch via `HtmlClient` -> parse -> return DTO.

From the Domain and Presentation perspective, this is indistinguishable from a normal API.

## Adding a New Feature

See the 12-step checklist in [AGENTS.md](../AGENTS.md).
