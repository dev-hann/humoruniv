import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/atoms/scroll_to_top_button.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/providers/shared_preferences_provider.dart';
import 'package:humoruniv/presentation/widgets/feed_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  List<Override> overrides() => [
    sharedPreferencesProvider.overrideWithValue(prefs),
    postDetailProvider.overrideWith(
      (ref, url) async => const Left(ServerFailure('')),
    ),
  ];

  group('FeedList', () {
    const posts = [
      BoardPost(
        id: 1,
        title: '첫 글',
        url: 'u1',
        author: 'a1',
        date: '2026-05-15',
        recommendCount: 10,
        notRecommendCount: 0,
        commentCount: 1,
        viewCount: 100,
        thumbnailUrl: '',
      ),
      BoardPost(
        id: 2,
        title: '둘째 글',
        url: 'u2',
        author: 'a2',
        date: '2026-05-15',
        recommendCount: 20,
        notRecommendCount: 0,
        commentCount: 2,
        viewCount: 200,
        thumbnailUrl: '',
      ),
    ];

    testWidgets('should show skeleton cards when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedList(posts: [], isLoading: true)),
        ),
      );
      expect(find.byType(SkeletonFeedCard), findsWidgets);
    });

    testWidgets('should show error view when hasError', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedList(posts: [], hasError: true, errorMessage: '에러 발생'),
          ),
        ),
      );
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('에러 발생'), findsOneWidget);
    });

    testWidgets('should show empty view when posts is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedList(posts: [])),
        ),
      );
      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('should show a FeedCard per post when loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: const MaterialApp(
            home: Scaffold(body: FeedList(posts: posts)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FeedCard), findsNWidgets(2));
    });

    testWidgets('should show loading footer when isLoadingMore', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(
            home: Scaffold(
              body: FeedList(
                posts: [posts[0]],
                isLoadingMore: true,
                hasMore: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

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
          child: MaterialApp(
            home: Scaffold(body: FeedList(posts: manyPosts())),
          ),
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
          child: MaterialApp(
            home: Scaffold(body: FeedList(posts: manyPosts())),
          ),
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
          child: MaterialApp(
            home: Scaffold(body: FeedList(posts: manyPosts())),
          ),
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

    testWidgets('tapping scroll-to-top also triggers onRefresh callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      var refreshCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides(),
          child: MaterialApp(
            home: Scaffold(
              body: FeedList(
                posts: manyPosts(),
                onRefresh: () => refreshCalled = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(feedScrollable(), const Offset(0, -700));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ScrollToTopButton));
      await tester.pumpAndSettle();

      expect(refreshCalled, isTrue);
      expect(
        tester.state<ScrollableState>(feedScrollable()).position.pixels,
        0,
      );
    });

    testWidgets(
      'scroll-to-top button is absent in loading/error/empty states',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FeedList(posts: [], isLoading: true)),
          ),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FeedList(posts: [], hasError: true)),
          ),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FeedList(posts: [])),
          ),
        );
        expect(find.byType(ScrollToTopButton), findsNothing);
      },
    );

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
            child: MaterialApp(
              home: Scaffold(body: FeedList(posts: [posts[0]])),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pumpAndSettle();

        expect(find.byType(InlineVideoPlayer), findsOneWidget);
        expect(find.byIcon(Icons.close), findsNothing);
      },
    );
  });
}
