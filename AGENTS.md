# AGENTS.md

Guidelines for AI coding agents working on this project.

## Development Workflow: TDD

See [docs/TESTING.md](docs/TESTING.md) for full TDD cycle, enforcement tiers, and rules.

TDD is MANDATORY. Enforcement varies by code tier:

| Tier | Scope | TDD Cycle | Applies To |
|------|-------|-----------|------------|
| S (Strict) | Per test case | RED→GREEN per individual test case | Parsers, business logic, state management |
| A (Per-class) | Per class | RED→GREEN per class | DataSource, Repository, UseCase, Widget |
| B (Per-layer) | Per layer | Write tests then impl, no RED required | Entity, DTO, Failure, interfaces |

**CRITICAL**: Every implementation step MUST be followed by `flutter test`.
Skipping `flutter test` between steps is a PROHIBITED ACTION.

## Mandatory Checks Before Committing

Pre-commit hook (husky) enforces these automatically:

```bash
flutter analyze --no-fatal-infos
flutter test
```

Both must pass with zero errors. No exceptions.

Or use: `make check`

## Commands

| Command | Description |
|---------|-------------|
| `make check` | analyze + test (run before commit) |
| `make analyze` | lint check only |
| `make test` | all tests |
| `make coverage` | tests with coverage report |
| `make e2e` | E2E tests — Provider overrides, deterministic (needs device) |
| `make smoke` | Smoke tests — real network, live server (needs device + internet) |
| `make fix` | auto-fix lint issues |
| `make clean` | clean and re-fetch dependencies |

## Architecture Rules

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full details.

Key constraints:

- **Domain layer** MUST NOT import any external package (only pure Dart)
- **Presentation layer** MUST NOT directly import from Data layer
- **Data layer** implements Domain layer interfaces
- Dependency direction: Presentation -> Domain <- Data

## Coding Conventions

See [docs/CONVENTIONS.md](docs/CONVENTIONS.md) for full details.

## Product Direction

See [docs/PRODUCT_PLAN.md](docs/PRODUCT_PLAN.md) for feature roadmap, personas, UX specs, and scope. This document covers WHAT to build and HOW users interact with it.

See [docs/DESIGN.md](docs/DESIGN.md) for visual design rules. This document covers HOW things LOOK.

Current scope: **웃긴자료 (pds) board only.** Do not implement other boards until Phase 3.

## Feature Consensus Protocol

Before implementing any screen or significant feature, load and follow the `feature-consensus` skill:

```
skill({ name: "feature-consensus" })
```

This runs a multi-agent debate between @pm-reviewer (UX perspective) and @designer-reviewer (visual perspective). They negotiate in independent contexts until both agree on the specification. Only the final consensus result is returned to the main context for implementation.

**When to use**: New screens, significant new features, refactoring that changes behavior.
**When to skip**: Bug fixes, test additions, minor copy changes, refactoring without UX/UI changes.

## Prohibited Actions

- Writing implementation code without tests
- Writing test and implementation in the same tool call batch — they MUST be separate steps
- Proceeding to the next component before the current component is GREEN
- Writing multiple test files before writing any implementation code
- Skipping `flutter test` verification between RED and GREEN phases
- Importing `dio`, `html`, `charset_converter` in Domain layer
- Importing `data/` directly from `presentation/`
- Using `late` keyword (use nullable types or constructor injection)
- Adding comments unless explicitly requested
- Committing code with failing tests
- Skipping `flutter analyze` before committing

## Commit Convention

Use Conventional Commits:

```
feat: add board list parser
fix: fix EUC-KR decoding edge case
refactor: extract common parser utility
test: add post detail parser tests
docs: update architecture guide
chore: update dependencies
```

## When Adding a New Feature

Follow this checklist IN ORDER. Each step is a complete TDD cycle.
Do NOT proceed to step N+1 until step N is fully GREEN.

### Step 0: Feature Consensus
Run `skill({ name: "feature-consensus" })` to get PM/Designer agreement.

### Step 1: Domain Layer (Tier B — Per-layer)
1. Write Entity class (e.g., `lib/domain/entities/post.dart`)
2. Write Failure classes if needed (e.g., `lib/core/errors/failures.dart`)
3. Write Repository interface (e.g., `lib/domain/repositories/post_repository.dart`)
4. Write tests for all of the above
5. Run `flutter test test/unit/domain/` → Confirm GREEN

### Step 2: Parser (Tier S — Strict per-test-case)
For EACH test case:
1. Write ONE failing parser test
2. Run `flutter test test/unit/data/parsers/<parser>_test.dart` → Confirm RED
3. Write minimum parser code to pass
4. Run `flutter test test/unit/data/parsers/<parser>_test.dart` → Confirm GREEN
5. Repeat from 1 for next test case

After all parser test cases pass:
6. Refactor if needed → `flutter test` → Confirm still GREEN

### Step 3: DTO (Tier B — Per-layer)
1. Write DTO class with `toEntity()`
2. Write DTO tests
3. Run `flutter test test/unit/data/models/` → Confirm GREEN

### Step 4: DataSource (Tier A — Per-class)
1. Write ALL failing DataSource tests
2. Run `flutter test test/unit/data/api/` → Confirm RED
3. Write minimum DataSource implementation
4. Run `flutter test test/unit/data/api/` → Confirm GREEN

### Step 5: Repository Impl (Tier A — Per-class)
1. Write ALL failing repository tests
2. Run `flutter test test/unit/data/repositories/` → Confirm RED
3. Write minimum repository implementation
4. Run `flutter test test/unit/data/repositories/` → Confirm GREEN

### Step 6: UseCase (Tier A — Per-class)
1. Write ALL failing use case tests
2. Run `flutter test test/unit/domain/usecases/` → Confirm RED
3. Write minimum use case implementation
4. Run `flutter test test/unit/domain/usecases/` → Confirm GREEN

### Step 7: DI Registration
1. Register new dependencies in `lib/di/injection.dart`
2. Run `flutter analyze` → Confirm no errors

### Step 8: Provider (Tier A — Per-class)
1. Write ALL failing provider tests
2. Run `flutter test test/unit/core/` → Confirm RED
3. Write minimum provider implementation
4. Run `flutter test test/unit/core/` → Confirm GREEN

### Step 9: Widget/Screen (Tier A — Per-class)
1. Write ALL failing widget tests
2. Run `flutter test test/widget/` → Confirm RED
3. Write minimum widget implementation
4. Run `flutter test test/widget/` → Confirm GREEN

### Step 10: Integration Test
1. Write integration test wiring real layers
2. Run `flutter test test/integration/` → Confirm GREEN

### Step 11: E2E Test
1. Write E2E test for the user flow
2. Run `flutter test integration_test/` → Confirm GREEN

### Step 12: Final Check
1. Run `make check` → All tests pass, zero errors
2. Commit only when all pass

**RULE**: Every `flutter test` run in steps 1-11 is MANDATORY.
Skipping any of them is a PROHIBITED ACTION.
