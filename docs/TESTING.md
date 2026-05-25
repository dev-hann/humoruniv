# Testing

TDD is the core development methodology. See [AGENTS.md](../AGENTS.md) for workflow rules.

## TDD Cycle

Every feature MUST follow:

1. **RED** - Write a failing test. Run it. Confirm it fails.
2. **GREEN** - Write the minimum implementation to pass. Run it. Confirm it passes.
3. **REFACTOR** - Clean up code. Run tests again. All must still pass.

No implementation code may exist without a corresponding test.

## TDD Enforcement Tiers

Not all code requires the same level of TDD strictness.
Use this tier system to balance safety and efficiency.

### Tier S — Strict (Per Test Case)

For code with complex logic: parsers, state management, business rules.

Protocol:
1. Write ONE test case
2. Run `flutter test <file>` → MUST fail (RED)
3. Write minimum code to pass
4. Run `flutter test <file>` → MUST pass (GREEN)
5. Repeat from step 1 for next test case

Examples:
- `MainPageParser.parseBestPosts()` — each edge case individually
- `BoardListParser.parse()` — each edge case individually
- `PostDetailParser.parse()` — each edge case individually
- Complex state transitions in providers

### Tier A — Per Class

For code with moderate logic: data sources, repositories, use cases, widgets.

Protocol:
1. Write ALL test cases for the class
2. Run `flutter test <dir>/` → MUST fail (RED)
3. Write minimum implementation for the entire class
4. Run `flutter test <dir>/` → MUST pass (GREEN)

Examples:
- `HumorunivRemoteDsImpl`
- `PostRepositoryImpl`
- `GetBestPosts`, `GetPostDetail`, `GetBoardPosts`
- `HomeScreen`, `BoardScreen`, `PostDetailScreen`

### Tier B — Per Layer

For code with no logic: data classes, interfaces, type definitions.

Protocol:
1. Write all code in the layer (entities, interfaces)
2. Write all tests for the layer
3. Run `flutter test` → MUST pass (GREEN)

RED verification is not required — these have no logic to fail.

Examples:
- `Post`, `BoardPost`, `Comment` entities
- `PostDto`, `BoardPostDto`, `CommentDto` with `toEntity()`
- `Failure` hierarchy
- Abstract interfaces (`HtmlClient`, `PostRepository`)

### Tier Assignment Table

| Component | Tier | Reason |
|-----------|------|--------|
| Parser methods | S | Complex HTML parsing, many edge cases |
| Business logic / use cases | A | Moderate logic, mock-dependent |
| Repository implementations | A | Error handling, Either mapping |
| Data sources | A | Async, network interaction |
| Providers | A | State management wiring |
| Widgets / Screens | A | UI rendering, user interaction |
| Entities | B | Pure data, no logic |
| DTOs | B | Data + toEntity(), trivial logic |
| Failures | B | Exception hierarchy, no logic |
| Abstract interfaces | B | No implementation to test |
| Integration tests | A | Wiring verification |
| E2E tests | A | Full flow on device |
| Smoke tests | A | Real network verification |

## Strict Enforcement Rules

The following rules are NON-NEGOTIABLE regardless of tier.

### Every `flutter test` Run Is Mandatory

Every step that says "Run `flutter test`" in the AGENTS.md checklist
MUST be executed. The test output MUST be observed before proceeding.

### Prohibited Patterns

1. **Batch TDD** — Writing multiple test files then multiple implementation
   files without running tests in between. Each tier has its own cycle;
   follow it.

2. **Same-batch test+impl** — Writing test and implementation in the
   same tool call. Tests and implementations MUST be written in
   separate steps so the agent can observe RED.

3. **Skipping RED** — For Tier S and A, you MUST verify that tests
   fail before writing implementation. If a test passes immediately,
   either the test is wrong or the implementation already exists.

4. **Skipping test run** — Writing test → implementation → running
   `flutter test` once at the end. Each RED→GREEN transition requires
   its own `flutter test` execution.

5. **Proceeding before GREEN** — Do not start the next step until the
   current step's `flutter test` passes. If it fails, fix it first.

### Minimum Implementation Principle

During GREEN phase, write the MINIMUM code to make the test pass.

- Hardcoded return values are acceptable if that is what makes the test pass.
- Do not anticipate future tests.
- Refactoring comes after GREEN, not during.
- The next test case will force you to generalize.

## Test Levels

### 1. Unit Tests (`test/unit/`)

Isolated tests with all dependencies mocked via `mocktail`.

| Target | What to test | Mock |
|--------|-------------|------|
| Entity | Value equality, field access | None |
| Parser | HTML string → DTO | None (pure function) |
| DTO | `toEntity()` conversion | None |
| UseCase | Business logic, Either result | Repository |
| DataSource | Correct parser called, error handling | HtmlClient |
| Repository impl | Mapping, error handling | DataSource |
| Provider | State management, async flow | Repository via DI |
| Widget | Rendering, interaction | Provider overrides |

Parser test pattern:
```dart
test('should return list of posts when html contains valid best section', () {
  final html = File('test/fixtures/main_page.html').readAsStringSync();
  final result = MainPageParser.parseBestPosts(html);
  expect(result, isNotEmpty);
  expect(result.first.title, isNotEmpty);
});
```

Widget test pattern:
```dart
testWidgets('should display post titles when data loads', (tester) async {
  when(() => mockRepository.getBestPosts())
      .thenAnswer((_) async => Right(posts));

  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: HomeScreen())),
  );
  await tester.pumpAndSettle();

  expect(find.text('First Post'), findsOneWidget);
});
```

### 2. Widget Tests (`test/widget/`)

Test complete screens in isolation using `WidgetTester`.

- Render with `pumpWidget` and a test wrapper.
- Assert widget tree for data states: loading, success, error.
- Simulate interactions: `tap`, `scroll`, `enterText`.
- Use `ProviderScope` overrides or DI mock injection.

### 3. Integration Tests (`test/integration/`)

Wire up multiple real layers together with only the external boundary mocked.

- Real parsers + mock HtmlClient (returns fixture HTML instead of HTTP).
- Full chain: DataSource → Parser → Repository.
- Verify data flows correctly through all layers.
- No Riverpod/Flutter widget involvement.

### 4. E2E Tests (`integration_test/`)

Full app tests running on a real device or emulator using the `integration_test` package.

- Use **Provider overrides** to inject deterministic fake data — no real network calls.
- Safe to use `pumpAndSettle()` because there are no loading animations from network images.
- Test complete user flows: launch → data display → navigation → detail view → error states.
- Run with `flutter test integration_test/` — requires connected device/emulator.

### 5. Smoke Tests (`test/smoke/`)

Real network tests that verify parsers work against the live server.

- Fetch real HTML from `m.humoruniv.com` via `dart:io` HttpClient.
- Decode EUC-KR via `iconv` system command (cp949 → utf-8).
- Parse with real parsers and verify results.
- **Guarded by `SMOKE=1` environment variable**: skipped by default.
- Run with `SMOKE=1 flutter test test/smoke/`.
- No device required — runs in plain `flutter test` environment.

When to run:
- Before release.
- When humoruniv.com might have changed their HTML structure.
- Periodically (daily CI if available).

| Test | What it verifies |
|------|-----------------|
| `app_smoke_test.dart` | `/main.html` → MainPageParser → posts have title/url/recommendCount |
| `board_smoke_test.dart` | `/board/list.html` → BoardListParser → posts + pagination + sort |
| `detail_smoke_test.dart` | post URL → PostDetailParser → title/author/contentBlocks/comments/images |

## Test Level Decision Matrix

| Question | Answer → Test Level |
|----------|-------------------|
| "이 함수/클래스 단위 로직이 맞는가?" | Unit |
| "이 위젯이 제대로 렌더링되는가?" | Widget |
| "여러 레이어를 연결했을 때 데이터가 제대로 흐르는가?" | Integration |
| "앱 전체가 사용자 관점에서 작동하는가?" | E2E |
| "실서버 HTML 구조가 변경되어 파서가 고장났는가?" | Smoke |

## Fixture Management

- Store HTML samples in `test/fixtures/`.
- Capture real HTML from `m.humoruniv.com`.
- Naming: `{page_type}[_{variant}].html`
  - `main_page.html`
  - `board_list_pds.html`
  - `post_detail.html`
- Each parser MUST have at least one corresponding fixture.
- Commit fixtures to the repository.

Current fixtures:
| Fixture | Used by |
|---------|---------|
| `main_page.html` | `main_page_parser_test.dart`, `best_posts_integration_test.dart` |
| `board_list_pds.html` | `board_list_parser_test.dart` |
| `post_detail.html` | `post_detail_parser_test.dart`, `post_detail_integration_test.dart` |

## Mock Conventions

Use `mocktail` for all mocking.

```dart
class MockPostRepository extends Mock implements PostRepository {}

// In setUp:
registerFallbackValue(SortOption.all);

// In test:
when(() => mockRepo.getBestPosts())
    .thenAnswer((_) async => Right([testPost]));
```

Rules:
- One mock class per test file or shared in test helpers.
- Use `registerFallbackValue` for any `any()` matcher parameters.
- Use `when` + `thenAnswer` for async, `when` + `thenReturn` for sync.
- Use `verify` to assert interactions when behavior matters, not just result.
- Provider tests may inject mocks via `di.sl` (GetIt) with `setUp`/`tearDown` registration.

## Test Description Format

Use `should [expected] when [condition]`:

```dart
test('should return empty list when html has no post elements', () { ... });
test('should emit loading then data when fetch succeeds', () { ... });
test('should navigate to detail when post card is tapped', () { ... });
```

## Test File Organization

Mirror the `lib/` structure:

```
test/
├── fixtures/
│   ├── main_page.html
│   ├── board_list_pds.html
│   └── post_detail.html
├── unit/
│   ├── core/
│   │   ├── errors/
│   │   └── network/
│   ├── data/
│   │   ├── parsers/
│   │   ├── models/
│   │   ├── api/                          # datasources
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   ├── di/
│   ├── routes/
│   └── presentation/
│       ├── providers/
│       └── widgets/
├── widget/
│   └── presentation/screens/
├── integration/
└── smoke/
    ├── helpers.dart                      # fetchHtml() + EUC-KR decode
    ├── app_smoke_test.dart
    ├── board_smoke_test.dart
    └── detail_smoke_test.dart

integration_test/
├── app_e2e_test.dart                     # E2E (fake data, pumpAndSettle)
└── app_smoke_test.dart                   # E2E smoke (real network, pump)
```

## Current Test Counts

| Level | Files | Tests |
|-------|-------|-------|
| Unit | 29 | 170+ |
| Widget | 4 | 28+ |
| Integration | 2 | 6 |
| Smoke (test/smoke/) | 3 | 9 |
| E2E (integration_test/) | 2 | 7 |
| **Total** | **40+** | **220+** |

Run without smoke: `flutter test` (smoke tests auto-skip)
Run with smoke: `SMOKE=1 flutter test`
Run E2E: `flutter test integration_test/`

## Parser Resilience Testing

Every parser MUST be tested against these cases:

| Case | Expected behavior |
|------|-------------------|
| Valid HTML | Returns correctly populated DTOs |
| Empty string | Returns empty list or default DTO. No crash. |
| HTML with missing required elements | Returns empty list or default DTO. No crash. |
| HTML with malformed structure | Returns partial results or default. No crash. |

Parsers MUST never throw. They always return a valid result (empty/default on failure).

## Test Anti-Patterns

The following patterns are prohibited:

- **Mock echo**: Asserting the exact value that was set up in `when(...).thenReturn(...)`. This tests the mock, not the code.
- **No assertions**: A test without at least one `expect` is not a test.
- **Tautology**: Asserting conditions that are always true (e.g., `expect(list.length, greaterThan(-1))`).
- **Code duplication**: Copying implementation logic into test code and comparing outputs.
- **Testing private members**: Only test public API behavior.
- **Batch writing**: Writing tests and implementations in the same tool call without running `flutter test` in between (see Strict Enforcement Rules above).

## Commands

| Command | Purpose |
|---------|---------|
| `flutter test` | Run all tests (smoke skipped) |
| `SMOKE=1 flutter test` | Run all tests including smoke |
| `SMOKE=1 flutter test test/smoke/` | Run only smoke tests |
| `flutter test test/unit/` | Run only unit tests |
| `flutter test test/widget/` | Run only widget tests |
| `flutter test test/integration/` | Run only integration tests |
| `flutter test integration_test/` | Run E2E tests (requires device) |
| `flutter analyze` | Static analysis (0 errors required) |
