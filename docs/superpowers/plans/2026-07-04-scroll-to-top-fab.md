# Scroll-to-Top FAB Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a floating "scroll to top" button to the feed that instantly jumps the list to offset 0 when tapped, appearing only after the user has scrolled down.

**Architecture:** Presentation-only. A new dumb Atom (`ScrollToTopButton`) renders a fading circular button given `onTap` + `visible`; the existing `FeedList` organism (which already owns the `ScrollController`) tracks scroll offset, mounts the button in a `Stack` over the loaded list, and calls `jumpTo(0)` on tap. No domain/data/provider changes.

**Tech Stack:** Flutter, flutter_riverpod, flutter_test. Tokens from `lib/core/themes/` (`AppDurations`, `AppCurves`, `AppSpacing`). Atomic Design per `docs/DESIGN.md`.

**Spec:** [docs/superpowers/specs/2026-07-04-scroll-to-top-fab-design.md](../specs/2026-07-04-scroll-to-top-fab-design.md)

**TDD tier:** Both components are widgets → Tier A (per-class): write all failing tests → confirm RED → implement → confirm GREEN → commit. Each `flutter test` step is MANDATORY.

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| NEW | `lib/core/widgets/atoms/scroll_to_top_button.dart` | Atom: fading circular up-arrow button. Props `onTap`, `visible`. No domain/data/controller. |
| NEW | `test/unit/core/widgets/atoms/scroll_to_top_button_test.dart` | Atom widget tests. |
| EDIT | `lib/presentation/widgets/feed_list.dart` | Add `_showScrollTop` state + threshold; wrap loaded `ListView` in `Stack`; mount `ScrollToTopButton`; `jumpTo(0)` on tap. |
| EDIT | `test/unit/presentation/widgets/feed_list_test.dart` | Add wiring tests (visibility, scroll, tap, hide, regression). |

Conventions confirmed against existing code:
- Atom style ref: `lib/core/widgets/atoms/loading_indicator.dart` (uses `Theme.of(context).colorScheme`, `AppSpacing`).
- Atom test style ref: `test/unit/core/widgets/atoms/count_badge_test.dart` (plain `MaterialApp` + `Scaffold`, `testWidgets`, `find.byIcon`).
- FeedList test style ref: `test/unit/presentation/widgets/feed_list_test.dart` (ProviderScope + `postDetailProvider` override returning `Left(ServerFailure(''))`).

---

## Task 1: `ScrollToTopButton` Atom (Tier A — per-class)

**Files:**
- Create: `lib/core/widgets/atoms/scroll_to_top_button.dart`
- Test: `test/unit/core/widgets/atoms/scroll_to_top_button_test.dart`

- [ ] **Step 1: Write all failing atom tests**

Create `test/unit/core/widgets/atoms/scroll_to_top_button_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/atoms/scroll_to_top_button.dart';

void main() {
  Widget harness({required VoidCallback onTap, bool visible = true}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ScrollToTopButton(onTap: onTap, visible: visible),
        ),
      ),
    );
  }

  group('ScrollToTopButton', () {
    testWidgets('should display the up-arrow icon', (tester) async {
      await tester.pumpWidget(harness(onTap: () {}));
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('should be fully opaque when visible', (tester) async {
      await tester.pumpWidget(harness(onTap: () {}, visible: true));
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1.0,
      );
    });

    testWidgets('should be transparent when not visible', (tester) async {
      await tester.pumpWidget(harness(onTap: () {}, visible: false));
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0.0,
      );
    });

    testWidgets('should call onTap once when tapped and visible', (tester) async {
      var taps = 0;
      await tester.pumpWidget(harness(onTap: () => taps++, visible: true));
      await tester.tap(find.byType(ScrollToTopButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('should NOT call onTap when not visible', (tester) async {
      var taps = 0;
      await tester.pumpWidget(harness(onTap: () => taps++, visible: false));
      await tester.tap(find.byType(ScrollToTopButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('should expose 맨 위로 semantics label as a button', (tester) async {
      await tester.pumpWidget(harness(onTap: () {}));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == '맨 위로' &&
              w.properties.button == true,
        ),
        findsOneWidget,
      );
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/unit/core/widgets/atoms/scroll_to_top_button_test.dart`
Expected: FAIL — compilation error: target file `scroll_to_top_button.dart` does not exist (import fails / `ScrollToTopButton` undefined).

- [ ] **Step 3: Implement the atom**

Create `lib/core/widgets/atoms/scroll_to_top_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_durations.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';

class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({
    required this.onTap,
    this.visible = true,
    super.key,
  });

  final VoidCallback onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: Semantics(
          label: '맨 위로',
          button: true,
          child: Tooltip(
            message: '맨 위로',
            child: Material(
              color: colors.secondaryContainer,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: SizedBox(
                  width: AppSpacing.p40,
                  height: AppSpacing.p40,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/unit/core/widgets/atoms/scroll_to_top_button_test.dart`
Expected: PASS — all 6 tests green.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/atoms/scroll_to_top_button.dart test/unit/core/widgets/atoms/scroll_to_top_button_test.dart
git commit -m "feat: add ScrollToTopButton atom"
```

---

## Task 2: Wire `ScrollToTopButton` into `FeedList` (Tier A — per-class)

**Files:**
- Modify: `lib/presentation/widgets/feed_list.dart`
- Test: `test/unit/presentation/widgets/feed_list_test.dart`

- [ ] **Step 1: Write all failing wiring tests**

Add the following to `test/unit/presentation/widgets/feed_list_test.dart`. The existing `overrides()` and `posts` const are reused. Add a `manyPosts()` helper and four new `testWidgets` inside the existing `group('FeedList', ...)`.

Add these imports at the top of the test file (after the existing imports):

```dart
import 'package:humoruniv/core/widgets/atoms/scroll_to_top_button.dart';
```

Add inside `group('FeedList', ...)`, after the existing `isLoadingMore` test:

```dart
    List<BoardPost> manyPosts({int count = 30}) => List.generate(
      count,
      (i) => BoardPost(
        id: 100 + i,
        title: '글 $i',
        url: 'u$i',
        author: 'a',
        date: '2026-07-04',
        recommendCount: 0,
        notRecommendCount: 0,
        commentCount: 0,
        viewCount: 0,
        thumbnailUrl: '',
      ),
    );

    Finder feedScrollable() => find.descendant(
      of: find.byType(FeedList),
      matching: find.byType(Scrollable),
    );

    Finder feedOpacity() => find.descendant(
      of: find.byType(ScrollToTopButton),
      matching: find.byType(AnimatedOpacity),
    );

    testWidgets('scroll-to-top button is hidden at top of loaded feed', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(home: Scaffold(body: FeedList(posts: manyPosts()))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ScrollToTopButton), findsOneWidget);
      expect(tester.widget<AnimatedOpacity>(feedOpacity()).opacity, 0.0);
    });

    testWidgets('scroll-to-top button appears after scrolling past threshold', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(home: Scaffold(body: FeedList(posts: manyPosts()))),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(feedScrollable(), const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(tester.widget<AnimatedOpacity>(feedOpacity()).opacity, 1.0);
    });

    testWidgets('tapping scroll-to-top jumps feed back to offset 0', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(home: Scaffold(body: FeedList(posts: manyPosts()))),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(feedScrollable(), const Offset(0, -700));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ScrollToTopButton));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScrollableState>(feedScrollable()).position.pixels,
        0,
      );
      expect(tester.widget<AnimatedOpacity>(feedOpacity()).opacity, 0.0);
    });

    testWidgets(
      'scroll-to-top button is absent in loading/error/empty states',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FeedList(posts: [], isLoading: true))),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FeedList(posts: [], hasError: true))),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FeedList(posts: []))),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);
      },
    );
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/unit/presentation/widgets/feed_list_test.dart`
Expected: FAIL — the new tests fail. The "hidden at top" test fails because the loaded branch returns a bare `ListView` (no `ScrollToTopButton` in tree → `find.byType(ScrollToTopButton)` findsNothing → `findsOneWidget` fails). Existing tests still pass (regression baseline confirmed).

- [ ] **Step 3: Implement the wiring**

Edit `lib/presentation/widgets/feed_list.dart`:

3a. Add imports (after the existing imports, before `import 'package:humoruniv/domain/entities/board_post.dart';` is fine — just add two lines with the other `humoruniv` imports):

```dart
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/scroll_to_top_button.dart';
```

3b. In `_FeedListState`, add a threshold constant and a visibility flag. Replace the field declaration block:

```dart
class _FeedListState extends State<FeedList> {
  final ScrollController _controller = ScrollController();
```

with:

```dart
class _FeedListState extends State<FeedList> {
  static const double _kShowScrollTopOffset = 600.0;

  final ScrollController _controller = ScrollController();
  bool _showScrollTop = false;
```

3c. Extend `_onScroll` to track visibility. Replace:

```dart
  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      widget.onLoadMore?.call();
    }
  }
```

with:

```dart
  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      widget.onLoadMore?.call();
    }
    final shouldShow = position.pixels > _kShowScrollTopOffset;
    if (shouldShow != _showScrollTop) {
      setState(() => _showScrollTop = shouldShow);
    }
  }
```

3d. Wrap the loaded `ListView.builder` in a `Stack` with the button. Replace the final `return ListView.builder(...)` block:

```dart
    return ListView.builder(
      controller: _controller,
      itemCount: widget.posts.length + extra,
      itemBuilder: (context, index) {
        if (index == widget.posts.length) {
          if (widget.loadMoreError != null) {
            return LoadMoreError(
              message: '불러오기 실패',
              onRetry: widget.onRetryLoadMore ?? () {},
            );
          }
          if (widget.isLoadingMore) {
            return const LoadingIndicator();
          }
          return const SizedBox.shrink();
        }
        final post = widget.posts[index];
        return FeedCardItem(
          post: post,
          isRead: widget.readIds.contains(post.id),
        );
      },
    );
```

with:

```dart
    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          itemCount: widget.posts.length + extra,
          itemBuilder: (context, index) {
            if (index == widget.posts.length) {
              if (widget.loadMoreError != null) {
                return LoadMoreError(
                  message: '불러오기 실패',
                  onRetry: widget.onRetryLoadMore ?? () {},
                );
              }
              if (widget.isLoadingMore) {
                return const LoadingIndicator();
              }
              return const SizedBox.shrink();
            }
            final post = widget.posts[index];
            return FeedCardItem(
              post: post,
              isRead: widget.readIds.contains(post.id),
            );
          },
        ),
        Positioned(
          right: AppSpacing.p16,
          bottom: AppSpacing.p16,
          child: ScrollToTopButton(
            visible: _showScrollTop,
            onTap: () {
              if (_controller.hasClients) {
                _controller.jumpTo(0);
              }
            },
          ),
        ),
      ],
    );
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/unit/presentation/widgets/feed_list_test.dart`
Expected: PASS — all existing + 4 new tests green. (If the "appears after scrolling" test still fails because 30 posts do not yield ≥700px of scroll at 400×600, increase the `count` in `manyPosts({int count = 30})` to 60.)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/feed_list.dart test/unit/presentation/widgets/feed_list_test.dart
git commit -m "feat: wire scroll-to-top FAB into feed"
```

---

## Task 3: Final Check

- [ ] **Step 1: Full analyze + test**

Run: `make check`
Expected: `flutter analyze --no-fatal-infos` reports 0 issues; all tests pass.

- [ ] **Step 2: (No commit needed unless Task 3 surfaced changes)**

If `make check` passes clean, no further commit (Task 2 already committed the feature). If any fix-up was required, commit it with `fix:` prefix.

---

## Out of Scope (per spec §8)

- AppBar-title tap-to-top, animated glide, scroll-position persistence, detail/comments screen buttons, best-filter UI.
