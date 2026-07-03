# Design: Scroll-to-Top FAB (Feed)

- **Date**: 2026-07-04
- **Status**: Approved — awaiting implementation
- **Scope**: Phase 1 read-only feed, 웃긴자료 (pds) board only
- **Parent design**: [2026-06-28-instagram-feed-design.md](2026-06-28-instagram-feed-design.md)

## 1. Overview

After browsing deep into the infinite feed, returning to the top currently
requires manual fling-scrolling, which is slow on a long list. Add a
floating "scroll to top" affordance that jumps the feed to offset 0 in a
single tap.

### Locked decisions

1. **Trigger**: a single **Floating Action Button (FAB)** — circular
   button that appears bottom-right after the user scrolls down. Tap to
   jump to top. (AppBar-title-tap considered and rejected: less
   discoverable.)
2. **Scroll behavior**: **instant `jumpTo(0)`**, not an animated glide.
   Directly fixes the "too slow" complaint and avoids jank on very long
   lists. The button's own show/hide still animates (see §3).
3. **Visibility**: hidden while at/near the top; appears once the user
   scrolls past a threshold; hides again when back at the top.
4. **Placement scope**: only on the **loaded** feed branch. Never shown
   over loading skeletons, error, or empty states (nothing to scroll).
5. **No new state**: purely a presentation affordance. No domain / data /
   provider changes. Pagination and pull-to-refresh are untouched.

## 2. Architecture

Presentation-only change. Dependency direction is unchanged
(Presentation → Domain ← Data); no layer below presentation is touched.

### Components

| Component | Level | Location | Responsibility |
|-----------|-------|----------|----------------|
| `ScrollToTopButton` | Atom | `lib/core/widgets/atoms/scroll_to_top_button.dart` | Render a circular up-arrow button that fades in/out. Pure presentational — takes `onTap` + `visible`; owns no controller, no domain types. |
| `FeedList` (edit) | Organism | `lib/presentation/widgets/feed_list.dart` | Owns the existing `ScrollController`. Adds scroll-offset tracking, mounts `ScrollToTopButton` over the loaded list, calls `jumpTo(0)` on tap. |

### Why an Atom for the button

Per DESIGN.md, atoms are "single visual element, no domain knowledge" and
"MUST NOT import from domain/ or data/. They receive all data via
constructor parameters." The button is exactly this: it knows nothing
about posts, controllers, or scrolling — it only reports taps and renders
itself visible or not. This keeps it reusable and unit-testable in
isolation.

### Why the Stack lives inside FeedList

The `ScrollController` is already encapsulated in `_FeedListState`.
Lifting it out to `HomeScreen` (to use `Scaffold.floatingActionButton`)
would leak an internal concern across the boundary. Instead `FeedList`
wraps only its loaded `ListView` branch in a `Stack` and `Positioned`s the
button bottom-right. Encapsulation preserved; `HomeScreen` is unchanged.

## 3. Visual & Motion

- **Icon**: `Icons.arrow_upward_rounded`.
- **Shape**: small circular container (Material 3 secondary container tone
  for light/dark parity; uses theme colors, no hardcoded values).
- **Show/hide animation**: `AnimatedOpacity` —
  `duration: AppDurations.fast` (150 ms),
  `curve: AppCurves.standard` (`easeInOut`). When hidden, also wrapped in
  `IgnorePointer` so it cannot intercept touches at opacity 0.
  - DESIGN.md Motion Rules require all animations to use the duration/curve
    tokens — no hardcoded `Duration`/`Curves`. Honored.
- **Position**: `Positioned` bottom-right using `AppSpacing` insets (e.g.
  `p16` from each edge) so it sits clear of content and the load-more
  footer.
- **Size**: small (`AppSpacing.p40`) to avoid dominating the feed.

### Threshold

The button appears once `scrollOffset > kScrollTopThreshold`. The
threshold is **one viewport-ish distance** so the button shows precisely
when the top is genuinely far away. Chosen constant:

- `_kShowScrollTopOffset = 600.0` (≈ one large feed card). Private const
  in `feed_list.dart`. Tunable.

## 4. Behavior Detail (`FeedList`)

`_FeedListState` already has `_onScroll` for pagination. Extend it:

1. Compute `shouldShow = position.pixels > _kShowScrollTopOffset`.
2. If `shouldShow != _showScrollTop`, `setState` to flip the flag.
3. The `Stack` renders `ScrollToTopButton(visible: _showScrollTop,
   onTap: () => _controller.jumpTo(0))`.

Guarded exactly like the existing pagination code with
`if (!_controller.hasClients) return;` first.

`jumpTo` throws if the controller has no clients or the position isn't a
fixed/scrollable one; the loaded `ListView` branch always attaches the
controller, so the tap callback is only ever mounted when safe.

### Branches (unchanged except the loaded one)

| State | Renders FAB? |
|-------|--------------|
| `isLoading` (skeletons) | No |
| `hasError` | No |
| `posts.isEmpty` | No |
| Loaded (normal list) | Yes — wrapped in `Stack` |

## 5. Accessibility

Per DESIGN.md "Accessibility Requirements":

- `Semantics(label: '맨 위로', button: true)` wrapping the tappable area.
- `tooltip: '맨 위로'` for hover/long-press announcement.
- The button is operable by single tap; no drag/precision required.
- Color is not the sole indicator (the up-arrow glyph is the indicator).

## 6. Testing Strategy

This is presentation-only, so AGENTS.md Steps 1–8 (domain → provider) are
skipped. Implementation begins at the widget layer (Step 9) and ends at
the Final Check (Step 12).

### 6.1 `ScrollToTopButton` atom — Tier S (strict, per-test-case)

Per DESIGN.md "Adding New Component": write widget tests for all variants
and states before/at coding. One RED → GREEN cycle each:

- Renders the up-arrow icon when present.
- `visible: true` → opacity 1 (fully opaque / found).
- `visible: false` → opacity 0 (transparent / not interactive; wrapped in
  `IgnorePointer`).
- Tap invokes the `onTap` callback exactly once.
- `Semantics` label `'맨 위로'` is present.

File: `test/unit/core/widgets/atoms/scroll_to_top_button_test.dart`

### 6.2 `FeedList` wiring — Tier A (per-class)

Write all failing cases, then implement. Cases:

- FAB **absent** initially (at offset 0).
- FAB **absent** in `isLoading` / `hasError` / `posts.isEmpty`.
- FAB **appears** after scrolling past `_kShowScrollTopOffset`.
- Tapping the FAB sets scroll offset to `0`.
- FAB **hides** again after returning to the top.
- Existing pagination still works (regression guard).

File: edit `test/unit/presentation/widgets/feed_list_test.dart`.

To make the list long enough to scroll in a widget test, render posts as
tall fixed-height boxes (or many posts) inside a `SizedBox`-bounded
viewport so `maxScrollExtent > threshold`.

### 6.3 Final Check

- `make check` (analyze + test) → zero errors before commit.

## 7. Files

| Action | Path |
|--------|------|
| NEW | `lib/core/widgets/atoms/scroll_to_top_button.dart` |
| NEW | `test/unit/core/widgets/atoms/scroll_to_top_button_test.dart` |
| EDIT | `lib/presentation/widgets/feed_list.dart` |
| EDIT | `test/unit/presentation/widgets/feed_list_test.dart` |

No changes to: domain, data, providers, DI, routes, themes (reuses
existing `AppDurations` / `AppCurves` / `AppSpacing` tokens), or
`HomeScreen`.

## 8. Out of Scope

- AppBar-title tap-to-top (rejected; less discoverable).
- Animated glide to top (rejected; `jumpTo` chosen for instant feedback).
- Persisting/restoring scroll position across app restarts.
- Scroll-to-top on the post-detail or comments screens.
- Best-filter / sort UI (still deferred per parent design).
