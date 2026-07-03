# Design: Inline Video Playback (Feed)

- **Date**: 2026-07-04
- **Status**: Approved — awaiting implementation
- **Scope**: Phase 1 read-only feed, 웃긴자료 (pds) board only
- **Parent design**: [2026-06-28-instagram-feed-design.md](2026-06-28-instagram-feed-design.md)

## 1. Overview

Today a video in the feed is shown as a **static thumbnail**. Tapping the
thumbnail anywhere pushes a **fullscreen** route (`Navigator.push` +
`MaterialPageRoute(fullscreenDialog)`) that hosts `InlineVideoPlayer`. Users
must leave the feed to watch, which is disruptive.

Change the interaction so the video plays **in place**: a dedicated play
button on the thumbnail swaps the thumbnail for the player right inside the
feed card, and the video starts muted immediately. Fullscreen is still
available on demand via the player's own fullscreen button.

### Locked decisions

1. **Trigger**: an explicit **play (▶) button** overlaying the thumbnail.
   Pressing it (not a generic tap on the whole thumbnail) starts playback.
   Chosen over "tap anywhere on thumbnail" for a clear, accidental-proof
   affordance.
2. **On press**: the thumbnail is replaced **in place** with
   `InlineVideoPlayer`, which **autoplays muted** in a single action. No
   second step, no fullscreen navigation.
3. **Audio**: starts **muted**; the user unmutes via the controller's mute
   toggle button (existing control bar).
4. **Fullscreen**: the inline player keeps its **fullscreen button**, which
   still pushes the existing `_FullscreenVideoPlayer` route. Inline is the
   default; fullscreen is opt-in.
5. **Single playback**: only **one** video plays at a time. Starting video B
   pauses video A. Enforced by a central Riverpod coordinator.
6. **Scroll / swipe away**: a playing video **auto-pauses** when it scrolls
   significantly out of view or is swiped off in the media carousel. It does
   **not** auto-resume on return — the user must press play again. Detection
   via `visibility_detector` (one mechanism covers both scroll and swipe).
7. **Lazy init**: only the video whose play button is pressed loads a
   `VideoPlayerController`. Untouched thumbnails stay as cheap static images
   (memory-friendly).

## 2. Architecture

Presentation-layer change only. Dependency direction is unchanged
(Presentation → Domain ← Data); no layer below presentation is touched. The
domain `VideoBlock` entity already carries everything needed (`url`,
`thumbnailUrl`, `isGifConversion`).

### Components

| Component | Level | Location | Responsibility |
|-----------|-------|----------|----------------|
| `FeedVideoPlaybackNotifier` | Provider | `lib/core/providers/feed_video_playback_provider.dart` (NEW) | Tracks the single active video identity `(postId, blockIndex)`. Exposes `activeVideoId` and `setActive(postId, blockIndex)` / `clear()`. Pure state; owns no controllers. |
| `InlineVideoPlayer` (edit) | Molecule | `lib/core/widgets/molecules/inline_video_player.dart` | Becomes a `ConsumerStatefulWidget`. Adds `autoplay` and optional `videoId` params. When `videoId` is set, watches `activeVideoId` and pauses when not active; wraps itself in `VisibilityDetector` to pause when not visible. When `videoId` is null, behaves standalone (current fullscreen-route usage). |
| `FeedImageCarousel` (edit) | Molecule | `lib/core/widgets/molecules/feed_image_carousel.dart` | `_buildVideoPage` renders a thumbnail + explicit play button. Local state records which video index is "expanded". Play-button press swaps the thumbnail for `InlineVideoPlayer(autoplay: true, videoId: ...)`. The `onVideoTap` prop is removed (playback is now internal). Gains a `postId` param (from `FeedCard`) so each player can be given a unique `videoId`. |
| `FeedCard` (edit) | Molecule | `lib/core/widgets/molecules/feed_card.dart` | Drops the `onVideoTap` param it currently forwards to `FeedImageCarousel`; instead passes `post.id` as `postId`. |
| `FeedCardItem` / `FeedList` (edit) | Organism | `lib/presentation/widgets/feed_list.dart` | Removes the `Navigator.push` fullscreen callback and the `onVideoTap` it passes into `FeedCard`. |

### Why a provider for single-playback

Each `InlineVideoPlayer` owns its own `VideoPlayerController` as local state
(unchanged). To guarantee "only one plays at a time" declaratively, a tiny
Riverpod notifier holds the **identity** of the active video. A player
watches that identity: when it is no longer the active one, it pauses itself.
This avoids passing raw `VideoPlayerController` references around (lifecycle-
fragile) and is trivially unit-testable.

### Identity model

`VideoId` is a value pair `{ postId, blockIndex }` — `postId` identifies the
feed card, `blockIndex` identifies which `VideoBlock` within the post's media
carousel. Two different posts' videos and two videos within one post are both
distinguishable.

## 3. Visual & Motion

- **Play button**: a circular, semi-transparent overlay centered on the
  thumbnail with `Icons.play_arrow_rounded`. Uses theme colors (no hardcoded
  values); sized via `AppSpacing` tokens. Distinct, tappable target (not the
  whole thumbnail area).
- **Swap transition**: thumbnail → player is an immediate replacement (the
  player shows its own poster/first-frame while initializing). No bespoke
  hero animation (YAGNI).
- **Controls**: the existing inline control bar is reused as-is — play/pause
  center icon, mute toggle, fullscreen button, 3 s auto-hide. No new chrome.

## 4. Behavior Detail

### 4.1 Play-button press (`FeedImageCarousel._buildVideoPage`)

1. Thumbnail renders with the play-button overlay.
2. On press: `setState` marks this `blockIndex` as expanded; the builder
   returns `InlineVideoPlayer(block: video, autoplay: true, videoId: VideoId(postId: widget.postId, blockIndex))`
   instead of the thumbnail. `postId` is supplied by `FeedCard` from
   `post.id`.
3. `InlineVideoPlayer.initState` (autoplay true) initializes the controller
   and calls `.play()` once ready (muted).

### 4.2 Single-playback coordination (`InlineVideoPlayer`)

- On play start, call `ref.read(feedVideoPlaybackProvider.notifier).setActive(videoId)`.
- `ref.watch(feedVideoPlaybackProvider)` → when the active id is no longer
  `videoId`, call `.pause()` (if playing). Do not auto-resume when it
  becomes active again — the press is the single source of "play intent".

### 4.3 Visibility pause (`InlineVideoPlayer`)

- Wrap the player body in `VisibilityDetector` keyed by `videoId`.
- On `visibleFraction < kPauseThreshold` (0.4): if playing, `.pause()`.
- On becoming visible again: **no action** (no auto-resume).

`kPauseThreshold = 0.4` covers both feed-scroll-away and carousel-swipe-away
(PageView neighbor pages report ~0 visibility), so a single mechanism handles
both. A private const in the player file; tunable.

### 4.4 Carousel page change

When the media `PageView`'s current page changes away from a video page, that
video's `VisibilityDetector` already reports ~0 → it pauses via §4.3. No
separate `onPageChanged` wiring is required (belt-and-suspenders avoided to
keep one source of truth).

### 4.5 Fullscreen button (unchanged path)

The inline player's existing fullscreen icon still calls `_enterFullscreen()`
→ `Navigator.push(_FullscreenVideoPlayer(...))`. That route is standalone
(`videoId` null) and unaffected by the coordinator.

## 5. Accessibility

Per DESIGN.md "Accessibility Requirements":

- Play button carries `Semantics(label: '재생', button: true)` and a
  `tooltip`.
- Mute/fullscreen controls already have tooltips; reuse them.
- Operable by single tap; no precision drag required.
- Color is not the sole indicator (the play glyph is the indicator).

## 6. Testing Strategy

Presentation-layer change; AGENTS.md Steps 1–8 partially apply. The provider
(Step 8 tier) is the first new unit, then widgets (Step 9).

### 6.1 `FeedVideoPlaybackNotifier` — Tier A (per-class)

Write all failing cases, then implement. Cases:

- Initial `activeVideoId` is null.
- `setActive(A)` → active is A.
- `setActive(B)` while A active → active is B (replaces, single-slot).
- `clear()` → active is null.
- `setActive(A)` again after clear → active is A.

File: `test/unit/core/providers/feed_video_playback_provider_test.dart` (NEW)

### 6.2 `InlineVideoPlayer` — Tier A (per-class)

Cases (build with a mocked/fake `VideoPlayerController` platform where
needed):

- `autoplay: true` → controller `play()` is called after init.
- `autoplay: false` → controller stays paused after init (regression of
  current fullscreen-route behavior).
- `videoId` set, active id becomes a different one → player pauses.
- `videoId` set, visibleFraction drops below threshold while playing →
  pauses.
- Becoming visible again does **not** auto-play.
- `videoId` null (standalone) → ignores coordinator (regression guard for
  fullscreen route).

File: edit `test/unit/core/widgets/molecules/inline_video_player_test.dart`

### 6.3 `FeedImageCarousel` — Tier A (per-class)

Cases:

- Renders a thumbnail + play button for a video page.
- Pressing the play button swaps the thumbnail for `InlineVideoPlayer`
  (autoplay true, with a `videoId`).
- Image pages are unaffected.

File: `test/unit/core/widgets/molecules/feed_image_carousel_test.dart` (NEW
or edit if one exists)

### 6.4 `FeedList` regression — Tier A

- No fullscreen route is pushed on video interaction anymore (the
  `Navigator.push` callback is gone).
- Existing pagination / scroll behavior unchanged.

File: edit `test/unit/presentation/widgets/feed_list_test.dart`

### 6.5 Final Check

- `make check` (analyze + test) → zero errors before commit.

## 7. Files

| Action | Path |
|--------|------|
| EDIT | `pubspec.yaml` (add `visibility_detector`) |
| NEW | `lib/core/providers/feed_video_playback_provider.dart` |
| NEW | `test/unit/core/providers/feed_video_playback_provider_test.dart` |
| EDIT | `lib/core/widgets/molecules/inline_video_player.dart` |
| EDIT | `test/unit/core/widgets/molecules/inline_video_player_test.dart` |
| EDIT | `lib/core/widgets/molecules/feed_image_carousel.dart` |
| EDIT | `lib/core/widgets/molecules/feed_card.dart` |
| NEW/EDIT | `test/unit/core/widgets/molecules/feed_image_carousel_test.dart` |
| EDIT | `lib/presentation/widgets/feed_list.dart` |
| EDIT | `test/unit/presentation/widgets/feed_list_test.dart` |

No changes to: domain entities, data layer, DI (the provider is
auto-disposable, no manual registration needed), routes, themes (reuses
existing tokens). `HomeScreen` is unchanged.

## 8. Out of Scope

- Scroll-into-view **autoplay** (TikTok/Reels style) — rejected; user chose
  explicit play-button press.
- Auto-resume on scroll-back — rejected; press-to-play only.
- Comments videos (`lib/presentation/widgets/content_block_view.dart:117`) —
  keep existing fullscreen push.
- Refactor of `InlineVideoPlayer` ↔ `_FullscreenVideoPlayer` duplication —
  left as-is; does not block this change.
- Central controller registry / memory eviction of off-screen controllers —
  deferred; lazy init already limits controller count to pressed videos.
