# Conventions

Coding rules for this project. See [ARCHITECTURE.md](ARCHITECTURE.md) for layer boundaries. See [TESTING.md](TESTING.md) for testing rules.

## Dart Style

- Run `flutter analyze` before every commit. Zero warnings/errors.
- No `late` keyword. Use nullable types or constructor injection.
- Import order: `dart:` -> `package:` -> relative imports.
- No comments unless explicitly requested.

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Screen | `*_screen.dart` | `main_screen.dart` |
| Widget | descriptive, no suffix | `post_card.dart` |
| Provider | `*_provider.dart` | `post_provider.dart` |
| Entity | singular noun | `post.dart` |
| DTO | `*_dto.dart` | `post_dto.dart` |
| Parser | `*_parser.dart` | `main_page_parser.dart` |
| Use case | `verb_noun.dart` | `get_post_detail.dart` |
| Repository interface | `*_repository.dart` | `post_repository.dart` |
| Repository impl | `*_repository_impl.dart` | `post_repository_impl.dart` |
| Test | `*_test.dart` | `main_page_parser_test.dart` |
| Fixture | `*.html` | `main_page.html` |

## Naming Conventions

- Classes: `PascalCase`
- Variables, functions, methods: `camelCase`
- Private members: `_camelCase`
- Files, directories: `snake_case`
- Constants: `camelCase` (Dart convention)

## Error Handling

Use `Either<Failure, T>` from dartz throughout all layers.

Failure hierarchy:
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure { ... }
class NetworkFailure extends Failure { ... }
class ParseFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
```

Return pattern in Data layer:
```dart
try {
  final result = await _api.getSomething();
  return Right(result.toEntity());
} on ServerException {
  return Left(ServerFailure('...'));
}
```

## Parser Rules

Parsers convert raw HTML strings into typed DTOs.

- Parsers MUST be stateless with only static methods.
- Input: `String html` -> Output: `Dto` or `List<Dto>`.
- DOM selector failures MUST NOT crash. Return empty/default values.
- One parser per HTML page structure.
- Each parser MUST have corresponding fixture HTML in `test/fixtures/`.

Pattern:
```dart
class SomePageParser {
  static List<SomeDto> parse(String html) {
    final doc = parse(html);
    // query selectors, map to DTOs
    // return empty list on failure, never throw
  }
}
```

## DTO Rules

- DTOs live in `data/models/`.
- Each DTO MUST have a `toEntity()` method that returns the corresponding Domain entity.
- DTOs are the only bridge between Data and Domain for data transfer.

## Riverpod Provider Rules

- Providers call use cases, never repositories or API directly.
- Use `AsyncNotifierProvider` or `FutureProvider` for async data.
- Provider file names match the domain they serve: `post_provider.dart`.

## Architecture Enforcement

Layer import rules are enforced via `import_lint` (see `analysis_options.yaml`).

> **Note**: `import_lint` is currently disabled due to a Flutter SDK `meta` version conflict (see `analysis_options.yaml`). These rules will be enforced once the conflict is resolved in a future Flutter stable release.

- Domain layer: no `package:dio`, `package:html`, `package:charset_converter`, `package:flutter`
- Presentation layer: no direct imports from `data/`
- Data layer: no imports from `presentation/`

Violations appear as lint errors in `flutter analyze` and IDE.

## Testing

See [TESTING.md](TESTING.md) for all testing rules, levels, and conventions.
