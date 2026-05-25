# HumorUniv App

An unofficial Flutter mobile app for [humoruniv.com](https://m.humoruniv.com), a Korean humor community since 1998.

## How It Works

The app has no backend server. Instead, the Data layer fetches HTML directly from `m.humoruniv.com`, decodes EUC-KR to UTF-8, parses the DOM, and returns structured Dart objects. The rest of the app treats it like a normal API.

## Tech Stack

- **Flutter 3.41** / Dart 3.11
- **flutter_riverpod** - state management
- **dio** - HTTP client
- **html** - HTML DOM parsing
- **charset_converter** - EUC-KR decoding
- **dartz** - Either-based error handling
- **go_router** - navigation
- **get_it** - dependency injection
- **mocktail** - test mocking

## Quick Start

```bash
flutter pub get
flutter run
```

For detailed setup, see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Documentation

| Document | Description |
|----------|-------------|
| [AGENTS.md](AGENTS.md) | AI agent rules, TDD workflow, prohibited actions |
| [docs/PRODUCT_PLAN.md](docs/PRODUCT_PLAN.md) | Product definition, personas, UX specs, feature roadmap |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Clean architecture layers, dependency rules, data flow |
| [docs/DESIGN.md](docs/DESIGN.md) | Design system rules, tokens, components, accessibility |
| [docs/CONVENTIONS.md](docs/CONVENTIONS.md) | Coding style, naming, parser patterns |
| [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) | Environment setup, commands, build instructions |
| [docs/TESTING.md](docs/TESTING.md) | TDD tiers, test levels, enforcement rules |

## License

Unofficial fan project. All content belongs to humoruniv.com and its users.
