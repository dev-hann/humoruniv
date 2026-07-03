# Inline Video Playback (Feed) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make feed videos play in-place (inline, muted) when the user presses the play button on the thumbnail — instead of navigating to a fullscreen route — with single-playback coordination and pause-on-scroll-away.

**Architecture:** A tiny Riverpod `Notifier` (`FeedVideoPlaybackProvider`) holds the single "active" video identity. `InlineVideoPlayer` becomes a `ConsumerStatefulWidget`, gains `autoplay` + `videoId` params, watches the provider to pause when another video becomes active, and wraps itself in `VisibilityDetector` to pause when scrolled/swiped away. `FeedImageCarousel` swaps the thumbnail for the inline player on play-button press. The fullscreen `Navigator.push` path in `FeedCardItem` is removed; the player's own fullscreen button still works.

**Tech Stack:** Flutter, flutter_riverpod (^2.6.1), video_player (^2.11.1), visibility_detector (^0.4.0+2), mocktail, flutter_test.

**Spec:** [docs/superpowers/specs/2026-07-04-inline-video-playback-design.md](../specs/2026-07-04-inline-video-playback-design.md)

---

## File Structure

| Action | Path | Responsibility |
|--------|------|----------------|
| NEW | `lib/core/providers/feed_video_playback_provider.dart` | `VideoId` value type + `FeedVideoPlaybackNotifier` (single active id) + `feedVideoPlaybackProvider`. |
| NEW | `test/unit/core/providers/feed_video_playback_provider_test.dart` | Pure unit tests for the notifier + `VideoId` equality. |
| EDIT | `pubspec.yaml` | Add `visibility_detector`. |
| EDIT | `lib/core/widgets/molecules/inline_video_player.dart` | Consumer; add `autoplay`/`videoId`; provider-reactive pause; visibility pause. |
| EDIT | `test/unit/core/widgets/molecules/inline_video_player_test.dart` | Wrap in `ProviderScope`; add new-param acceptance test. |
| EDIT | `lib/core/widgets/molecules/feed_image_carousel.dart` | Play button → inline player; add `postId`; remove `onVideoTap`. |
| EDIT | `test/unit/core/widgets/molecules/feed_image_carousel_test.dart` | Add inline-playback test; add `postId` to existing tests. |
| EDIT | `lib/core/widgets/molecules/feed_card.dart` | Drop `onVideoTap`; pass `post.id` as `postId`. |
| EDIT | `lib/presentation/widgets/feed_list.dart` | Remove fullscreen `onVideoTap` callback + unused imports. |
| EDIT | `test/unit/presentation/widgets/feed_list_test.dart` | Add "no fullscreen on play" integration test. |

**Testing note (read before Task 3):** `video_player` cannot initialize in the pure widget-test environment (no platform), so controller-level mechanics (autoplay `.play()`, pause-on-inactive, pause-on-invisible) are **not** unit-asserted here — consistent with the existing `inline_video_player_test.dart`, which only asserts rendered icons. The single-playback *decision logic* lives entirely in the provider (fully unit-tested). The *wiring* (play button → inline player, no fullscreen route) is asserted structurally. Controller mechanics are verified by E2E (`make e2e`).

---

## Task 1: `FeedVideoPlaybackProvider` + `VideoId` (Tier A)

Pure state. No Flutter/widget dependency. This is the single-playback brain.

**Files:**
- Create: `lib/core/providers/feed_video_playback_provider.dart`
- Test: `test/unit/core/providers/feed_video_playback_provider_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/unit/core/providers/feed_video_playback_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('FeedVideoPlaybackNotifier', () {
    test('initial activeVideoId is null', () {
      expect(container.read(feedVideoPlaybackProvider), isNull);
    });

    test('setActive stores the given VideoId', () {
      const id = VideoId(postId: 1, blockIndex: 0);
      container.read(feedVideoPlaybackProvider.notifier).setActive(id);
      expect(container.read(feedVideoPlaybackProvider), id);
    });

    test('setActive replaces the previous VideoId (single-slot)', () {
      const a = VideoId(postId: 1, blockIndex: 0);
      const b = VideoId(postId: 2, blockIndex: 0);
      container.read(feedVideoPlaybackProvider.notifier).setActive(a);
      container.read(feedVideoPlaybackProvider.notifier).setActive(b);
      expect(container.read(feedVideoPlaybackProvider), b);
    });

    test('different post/block produce different VideoIds', () {
      expect(
        const VideoId(postId: 1, blockIndex: 0) ==
            const VideoId(postId: 1, blockIndex: 1),
        isFalse,
      );
      expect(
        const VideoId(postId: 1, blockIndex: 0).hashCode ==
            const VideoId(postId: 2, blockIndex: 0).hashCode,
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/core/providers/feed_video_playback_provider_test.dart`
Expected: FAIL — `feed_video_playback_provider.dart` does not exist (compilation error: target of URI doesn't exist).

- [ ] **Step 3: Write minimal implementation**

Create `lib/core/providers/feed_video_playback_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class VideoId {
  const VideoId({required this.postId, required this.blockIndex});
  final int postId;
  final int blockIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoId &&
          postId == other.postId &&
          blockIndex == other.blockIndex;

  @override
  int get hashCode => Object.hash(postId, blockIndex);
}

class FeedVideoPlaybackNotifier extends Notifier<VideoId?> {
  @override
  VideoId? build() => null;

  void setActive(VideoId id) {
    if (state == id) return;
    state = id;
  }
}

final feedVideoPlaybackProvider =
    NotifierProvider<FeedVideoPlaybackNotifier, VideoId?>(
  FeedVideoPlaybackNotifier.new,
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/core/providers/feed_video_playback_provider_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/providers/feed_video_playback_provider.dart test/unit/core/providers/feed_video_playback_provider_test.dart
git commit -m "feat: add feed video playback coordinator provider"
```

---

## Task 2: Add `visibility_detector` dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the dependency**

Run: `flutter pub add visibility_detector:^0.4.0+2`
This adds `visibility_detector: ^0.4.0+2` under `dependencies:` in `pubspec.yaml` and runs `pub get`.

- [ ] **Step 2: Verify it resolves**

Run: `flutter pub get`
Expected: exit 0, no version-solving errors.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add visibility_detector dependency"
```

---

## Task 3: `InlineVideoPlayer` — Consumer + autoplay/videoId + coordination (Tier A)

Convert the player to a `ConsumerStatefulWidget`, add `autoplay` and `videoId`, react to the provider (pause when another video becomes active), and pause when scrolled away via `VisibilityDetector`. `_FullscreenVideoPlayer` is **unchanged**.

**Files:**
- Modify: `lib/core/widgets/molecules/inline_video_player.dart`
- Test: `test/unit/core/widgets/molecules/inline_video_player_test.dart`

- [ ] **Step 1: Write the failing test (replace whole test file)**

Replace `test/unit/core/widgets/molecules/inline_video_player_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

Widget _wrapped(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('InlineVideoPlayer', () {
    testWidgets('should show play icon for non-GIF VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsWidgets);
    });

    testWidgets('should show muted icon by default for VideoBlock',
        (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('should show fullscreen icon for VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });

    testWidgets('should show time display for VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.text('0:00 / 0:00'), findsOneWidget);
    });

    testWidgets('should not show control bar for isGifConversion VideoBlock',
        (tester) async {
      const block = VideoBlock(
        url: 'https://example.com/clip.mp4',
        isGifConversion: true,
      );
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.byIcon(Icons.volume_off), findsNothing);
      expect(find.byIcon(Icons.fullscreen), findsNothing);
      expect(find.text('0:00 / 0:00'), findsNothing);
    });

    testWidgets(
        'should show center play button for isGifConversion VideoBlock',
        (tester) async {
      const block = VideoBlock(
        url: 'https://example.com/clip.mp4',
        isGifConversion: true,
      );
      await tester.pumpWidget(_wrapped(const InlineVideoPlayer(block: block)));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets(
        'should accept autoplay and videoId without breaking rendering',
        (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');
      await tester.pumpWidget(
        _wrapped(
          InlineVideoPlayer(
            block: block,
            autoplay: true,
            videoId: const VideoId(postId: 1, blockIndex: 0),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(InlineVideoPlayer), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/core/widgets/molecules/inline_video_player_test.dart`
Expected: FAIL — `autoplay`/`videoId` are not defined on `InlineVideoPlayer` (compile error), and existing tests fail because the widget now needs a `ProviderScope` ancestor once it becomes a `ConsumerStatefulWidget`.

- [ ] **Step 3: Write minimal implementation**

Edit `lib/core/widgets/molecules/inline_video_player.dart`.

**3a. Add imports** (top of file, after `import 'dart:async';`):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
```

**3b. Change the class declaration + state header.** Replace:

```dart
class InlineVideoPlayer extends StatefulWidget {
  const InlineVideoPlayer({required this.block, super.key});
  final VideoBlock block;

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayButton = true;
  bool _showControls = true;
  bool _isMuted = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initController();
  }
```

with:

```dart
class InlineVideoPlayer extends ConsumerStatefulWidget {
  const InlineVideoPlayer({
    required this.block,
    this.autoplay = false,
    this.videoId,
    super.key,
  });
  final VideoBlock block;
  final bool autoplay;
  final VideoId? videoId;

  @override
  ConsumerState<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends ConsumerState<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayButton = true;
  bool _showControls = true;
  bool _isMuted = true;
  Timer? _hideTimer;

  static const double _kPauseThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    ref.listen<VideoId?>(feedVideoPlaybackProvider, _onActiveChanged);
    _initController();
  }

  void _onActiveChanged(VideoId? previous, VideoId? next) {
    final id = widget.videoId;
    if (id == null) return;
    if (next != id &&
        _isInitialized &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _showPlayButton = true);
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final id = widget.videoId;
    if (id == null) return;
    if (info.visibleFraction < _kPauseThreshold &&
        _isInitialized &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _showPlayButton = true);
    }
  }
```

**3c. Autoplay on init.** In `_initController`, replace the `.then((_) { ... })` body:

```dart
      .then((_) {
            if (mounted) {
              setState(() => _isInitialized = true);
              _controller!.setLooping(true);
              _controller!.setVolume(0);
              _startHideTimer();
            }
          })
```

with:

```dart
      .then((_) {
            if (mounted) {
              setState(() => _isInitialized = true);
              _controller!.setLooping(true);
              _controller!.setVolume(_isMuted ? 0 : 1);
              if (widget.autoplay) {
                _controller!.play();
                _showPlayButton = false;
                final id = widget.videoId;
                if (id != null) {
                  ref
                      .read(feedVideoPlaybackProvider.notifier)
                      .setActive(id);
                }
              }
              _startHideTimer();
            }
          })
```

**3d. Set active on manual play.** In `_togglePlayPause`, replace the `else` (play) branch:

```dart
      } else {
        _controller!.play();
        _showPlayButton = false;
        _startHideTimer();
      }
```

with:

```dart
      } else {
        _controller!.play();
        _showPlayButton = false;
        final id = widget.videoId;
        if (id != null) {
          ref.read(feedVideoPlaybackProvider.notifier).setActive(id);
        }
        _startHideTimer();
      }
```

**3e. Wrap with `VisibilityDetector` in `build`.** Replace the existing `build` method of `_InlineVideoPlayerState`:

```dart
  @override
  Widget build(BuildContext context) {
    final isGif = widget.block.isGifConversion;
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    final player = GestureDetector(
      onTap: _isInitialized ? _handleVideoTap : null,
      child: AspectRatio(
        aspectRatio: _isInitialized ? _controller!.value.aspectRatio : 16 / 9,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_hasError)
                _buildError()
              else if (_isInitialized)
                ClipRect(
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),
                )
              else if (widget.block.thumbnailUrl != null)
                Image.network(
                  widget.block.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => _buildLoading(),
                )
              else
                _buildLoading(),
              if (!_hasError && !_isInitialized && !_showPlayButton)
                const CircularProgressIndicator(color: Colors.white),
              if (isGif)
                _buildGifOverlay()
              else
                _buildControlsOverlay(position, duration),
            ],
          ),
        ),
      ),
    );

    final id = widget.videoId;
    if (id == null) return player;
    return VisibilityDetector(
      key: ValueKey('inline-video-${id.postId}-${id.blockIndex}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: player,
    );
  }
```

Leave all other methods (`_buildGifOverlay`, `_buildControlsOverlay`, `_buildCenterPlayIcon`, `_buildBottomControls`, `_buildLoading`, `_buildError`, and the entire `_FullscreenVideoPlayer` class) **unchanged**.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/core/widgets/molecules/inline_video_player_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/molecules/inline_video_player.dart test/unit/core/widgets/molecules/inline_video_player_test.dart
git commit -m "feat: make inline video player autoplay + coordinate single playback"
```

---

## Task 4: Inline playback wiring — carousel + FeedCard + FeedCardItem (Tier A)

This is the core behavior change: pressing the play button on a feed video thumbnail swaps the thumbnail for the inline player instead of pushing a fullscreen route.

**Files:**
- Modify: `lib/core/widgets/molecules/feed_image_carousel.dart`
- Modify: `lib/core/widgets/molecules/feed_card.dart`
- Modify: `lib/presentation/widgets/feed_list.dart`
- Test: `test/unit/core/widgets/molecules/feed_image_carousel_test.dart`
- Test: `test/unit/presentation/widgets/feed_list_test.dart`

- [ ] **Step 1: Write the failing carousel test (replace whole test file)**

Replace `test/unit/core/widgets/molecules/feed_image_carousel_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';
import 'package:humoruniv/core/widgets/molecules/feed_image_carousel.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

void main() {
  group('FeedImageCarousel', () {
    testWidgets('single image shows no indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(
              imageUrls: ['https://example.com/a.jpg'],
              postId: 1,
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('1/1'), findsNothing);
    });

    testWidgets('multiple images show "1/N" indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(imageUrls: ['a', 'b', 'c'], postId: 1),
          ),
        ),
      );
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('swipe advances the indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(imageUrls: ['a', 'b'], postId: 1),
          ),
        ),
      );
      expect(find.text('1/2'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('tap calls onImageTap with index', (tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(
              imageUrls: const ['a', 'b'],
              postId: 1,
              onImageTap: (i) => tapped = i,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Image).first);
      expect(tapped, 0);
    });

    testWidgets(
        'pressing play button mounts inline player with autoplay and videoId',
        (tester) async {
      const block = VideoBlock(
        url: 'https://example.com/v.mp4',
        thumbnailUrl: 'https://example.com/t.jpg',
      );
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: FeedImageCarousel(
                imageUrls: [],
                videoBlocks: [block],
                postId: 7,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(InlineVideoPlayer), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      final player =
          tester.widget<InlineVideoPlayer>(find.byType(InlineVideoPlayer));
      expect(player.autoplay, isTrue);
      expect(player.videoId, const VideoId(postId: 7, blockIndex: 0));
    });
  });
}
```

- [ ] **Step 2: Write the failing feed_list integration test**

In `test/unit/presentation/widgets/feed_list_test.dart`, add these imports at the top (alongside the existing ones):

```dart
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
```

Then add this test inside the existing `group('FeedList', () { ... })`, after the last test:

```dart
    testWidgets(
        'tapping a video play button plays inline without opening fullscreen',
        (tester) async {
      final videoDetail = PostDetail(
        id: 1,
        title: '비디오 글',
        author: 'a',
        date: DateTime(2026, 7, 1),
        contentHtml: '',
        contentBlocks: const [
          VideoBlock(
            url: 'https://example.com/v.mp4',
            thumbnailUrl: 'https://example.com/t.jpg',
          ),
        ],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            postDetailProvider.overrideWith(
              (ref, url) async => Right(videoDetail),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: FeedList(posts: [posts[0]])),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.byType(InlineVideoPlayer), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/unit/core/widgets/molecules/feed_image_carousel_test.dart test/unit/presentation/widgets/feed_list_test.dart`
Expected: FAIL — `FeedImageCarousel` has no `postId` parameter (compile error), and the inline-player swap / no-fullscreen behavior does not exist yet.

- [ ] **Step 4: Implement the carousel**

Edit `lib/core/widgets/molecules/feed_image_carousel.dart`.

**4a. Add imports** at the top:

```dart
import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
```

**4b. Change the constructor + add state field.** Replace:

```dart
  const FeedImageCarousel({
    required this.imageUrls,
    this.videoBlocks = const [],
    this.onImageTap,
    this.onVideoTap,
    super.key,
  });
  final List<String> imageUrls;
  final List<VideoBlock> videoBlocks;
  final ValueChanged<int>? onImageTap;
  final ValueChanged<int>? onVideoTap;
```

with:

```dart
  const FeedImageCarousel({
    required this.imageUrls,
    required this.postId,
    this.videoBlocks = const [],
    this.onImageTap,
    super.key,
  });
  final List<String> imageUrls;
  final int postId;
  final List<VideoBlock> videoBlocks;
  final ValueChanged<int>? onImageTap;
```

In `_FeedImageCarouselState`, add an expanded-index field next to `int _page = 0;`:

```dart
  int _page = 0;
  int? _expandedVideoIndex;
```

**4c. Replace `_buildVideoPage`.** Replace the whole method:

```dart
  Widget _buildVideoPage(int index) {
    final video = widget.videoBlocks[index];
    return GestureDetector(
      onTap: widget.onVideoTap == null ? null : () => widget.onVideoTap!(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video.thumbnailUrl != null)
            Image.network(
              video.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: Colors.grey[900]!),
            )
          else
            ColoredBox(color: Colors.grey[900]!),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
```

with:

```dart
  Widget _buildVideoPage(int index) {
    if (index == _expandedVideoIndex) {
      return InlineVideoPlayer(
        block: widget.videoBlocks[index],
        autoplay: true,
        videoId: VideoId(postId: widget.postId, blockIndex: index),
      );
    }
    final video = widget.videoBlocks[index];
    return Stack(
      fit: StackFit.expand,
      children: [
        if (video.thumbnailUrl != null)
          Image.network(
            video.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(color: Colors.grey[900]!),
          )
        else
          ColoredBox(color: Colors.grey[900]!),
        Center(
          child: Semantics(
            label: '재생',
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  setState(() => _expandedVideoIndex = index),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 5: Update `FeedCard` (drop `onVideoTap`, pass `postId`)**

Edit `lib/core/widgets/molecules/feed_card.dart`.

Remove the `onVideoTap` constructor param and field. Replace:

```dart
  const FeedCard({
    required this.post,
    super.key,
    this.detail,
    this.detailLoading = false,
    this.onImageTap,
    this.onVideoTap,
    this.onCommentsTap,
    this.isRead = false,
  });
  final BoardPost post;
  final PostDetail? detail;
  final bool detailLoading;
  final ValueChanged<int>? onImageTap;
  final ValueChanged<int>? onVideoTap;
  final VoidCallback? onCommentsTap;
  final bool isRead;
```

with:

```dart
  const FeedCard({
    required this.post,
    super.key,
    this.detail,
    this.detailLoading = false,
    this.onImageTap,
    this.onCommentsTap,
    this.isRead = false,
  });
  final BoardPost post;
  final PostDetail? detail;
  final bool detailLoading;
  final ValueChanged<int>? onImageTap;
  final VoidCallback? onCommentsTap;
  final bool isRead;
```

In `_media()`, replace the `FeedImageCarousel(...)` construction:

```dart
      FeedImageCarousel(
        imageUrls: detail?.imageUrls ?? const [],
        videoBlocks: _videoBlocks,
        onImageTap: onImageTap,
        onVideoTap: onVideoTap,
      ),
```

with:

```dart
      FeedImageCarousel(
        imageUrls: detail?.imageUrls ?? const [],
        videoBlocks: _videoBlocks,
        onImageTap: onImageTap,
        postId: post.id,
      ),
```

- [ ] **Step 6: Update `FeedCardItem` (remove fullscreen `onVideoTap`)**

Edit `lib/presentation/widgets/feed_list.dart`.

Remove these two imports (now unused):

```dart
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
```

Remove the `videoBlocks` computation (lines that read):

```dart
    final videoBlocks =
        detail?.contentBlocks.whereType<VideoBlock>().toList() ??
        const <VideoBlock>[];
```

Remove the entire `onVideoTap:` argument from the `FeedCard(...)` call:

```dart
      onVideoTap: videoBlocks.isEmpty
          ? null
          : (i) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(child: InlineVideoPlayer(block: videoBlocks[i])),
                ),
                fullscreenDialog: true,
              ),
            ),
```

The resulting `FeedCard(...)` call inside `_FeedCardItemState.build` must be exactly:

```dart
    return FeedCard(
      post: widget.post,
      detail: detail,
      detailLoading: asyncDetail.isLoading,
      isRead: widget.isRead,
      onImageTap: !hasImages
          ? null
          : (i) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImageViewerScreen(
                  imageUrls: detail.imageUrls,
                  initialIndex: i,
                ),
                fullscreenDialog: true,
              ),
            ),
      onCommentsTap: !hasComments
          ? null
          : () => showFeedCommentsSheet(
              context,
              detail.comments,
              detail.commentCount,
            ),
    );
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `flutter test test/unit/core/widgets/molecules/feed_image_carousel_test.dart test/unit/presentation/widgets/feed_list_test.dart`
Expected: PASS (carousel: 5 tests; feed_list: 6 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/core/widgets/molecules/feed_image_carousel.dart lib/core/widgets/molecules/feed_card.dart lib/presentation/widgets/feed_list.dart test/unit/core/widgets/molecules/feed_image_carousel_test.dart test/unit/presentation/widgets/feed_list_test.dart
git commit -m "feat: play feed videos inline instead of opening fullscreen"
```

---

## Task 5: Final check

- [ ] **Step 1: Run full analyze + test suite**

Run: `make check`
Expected: `flutter analyze` with zero errors; all tests pass.

- [ ] **Step 2: If anything was fixed, commit**

If Step 1 required any fix-up edits, stage and commit them with `fix:` or `chore:` as appropriate. Otherwise nothing to commit.

---

## Verification (E2E, after this plan)

Because `video_player` cannot initialize in unit tests, verify these controller-level mechanics on a device/emulator (`make e2e` or manual):

- Pressing the play button starts muted playback in place (no fullscreen).
- Starting a second video pauses the first (single playback).
- Swiping the media carousel away from a playing video pauses it.
- Scrolling a playing video mostly off-screen pauses it; scrolling back does **not** auto-resume.
- The inline player's fullscreen button still opens the fullscreen route.
- The mute button unmutes; the player's own play/pause works.
