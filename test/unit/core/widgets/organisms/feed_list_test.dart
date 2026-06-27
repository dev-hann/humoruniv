import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/organisms/feed_list.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';

void main() {
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
        MaterialApp(
          home: Scaffold(
            body: FeedList(posts: const [], isLoading: true, onPostTap: (_) {}),
          ),
        ),
      );
      expect(find.byType(SkeletonFeedCard), findsWidgets);
    });

    testWidgets('should show error view when hasError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedList(
              posts: const [],
              hasError: true,
              errorMessage: '에러 발생',
              onPostTap: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('에러 발생'), findsOneWidget);
    });

    testWidgets('should show empty view when posts is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedList(posts: const [], onPostTap: (_) {}),
          ),
        ),
      );
      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('should show a FeedCard per post when loaded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedList(posts: posts, onPostTap: (_) {}),
          ),
        ),
      );
      expect(find.byType(FeedCard), findsNWidgets(2));
    });

    testWidgets('should show loading footer when isLoadingMore', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedList(
              posts: [posts[0]],
              isLoadingMore: true,
              hasMore: true,
              onPostTap: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should call onPostTap with the tapped post', (tester) async {
      BoardPost? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedList(posts: posts, onPostTap: (p) => tapped = p),
          ),
        ),
      );
      await tester.tap(find.text('첫 글'));
      expect(tapped?.id, 1);
    });
  });
}
