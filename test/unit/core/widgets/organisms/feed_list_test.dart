import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/organisms/feed_list.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';

void main() {
  List<Override> overrides() => [
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
  });
}
