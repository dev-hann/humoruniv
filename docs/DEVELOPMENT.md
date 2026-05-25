# Development

Environment setup and commands.

## Prerequisites

- Flutter 3.41+ (stable channel)
- Dart 3.11+
- Android Studio (for Android) or Xcode (for iOS)
- An emulator or physical device

## Setup

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Test

```bash
flutter test                    # All tests in test/
flutter test integration_test/  # E2E (needs device/emulator)
```

For detailed test commands and coverage, see [TESTING.md](TESTING.md).

## Analyze

```bash
flutter analyze
```

Must pass with zero issues before committing.

## Build

```bash
flutter build apk --release       # Android APK
flutter build appbundle --release # Android App Bundle
flutter build ios --release       # iOS
```

## Project Structure

```
lib/
├── core/           # Shared utilities, constants, network client
├── domain/         # Entities, repository interfaces, use cases
├── data/           # DTOs, parsers, API, data sources, repository impls
├── presentation/   # Screens, widgets, providers
├── di/             # Dependency injection setup
└── routes/         # Navigation configuration
```

For architecture details, see [ARCHITECTURE.md](ARCHITECTURE.md).
For coding rules, see [CONVENTIONS.md](CONVENTIONS.md).
For testing, see [TESTING.md](TESTING.md).
