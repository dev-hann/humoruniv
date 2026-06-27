import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/feed_media.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/molecules/text_post_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';

void main() {
  group('FeedCard', () {
    const mediaPost = BoardPost(
      id: 1,
      title: '미디어 게시글 제목',
      url: '/board/read.html?table=pds&number=1',
      author: '유머작가',
      date: '2026-05-15',
      recommendCount: 42,
      notRecommendCount: 1,
      commentCount: 10,
      viewCount: 500,
      thumbnailUrl: 'https://example.com/thumb.jpg',
    );

    const textPost = BoardPost(
      id: 2,
      title: '텍스트 전용 게시글',
      url: '/board/read.html?table=pds&number=2',
      author: '글쓴이',
      date: '2026-05-15',
      recommendCount: 42,
      notRecommendCount: 1,
      commentCount: 10,
      viewCount: 500,
      thumbnailUrl: '',
    );

    testWidgets('should display author nickname', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.text('유머작가'), findsOneWidget);
    });

    testWidgets('should display recommend, comment and view counts', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.text('42'), findsWidgets);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('should show FeedMedia when thumbnailUrl is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.byType(FeedMedia), findsOneWidget);
      expect(find.byType(TextPostCard), findsNothing);
    });

    testWidgets('should show TextPostCard when thumbnailUrl is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: textPost)),
        ),
      );
      expect(find.byType(TextPostCard), findsOneWidget);
      expect(find.byType(FeedMedia), findsNothing);
    });

    testWidgets('should show title in caption for media post', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.text('미디어 게시글 제목'), findsOneWidget);
    });

    testWidgets('should show BEST badge when recommendCount >= 500', (
      tester,
    ) async {
      const best = BoardPost(
        id: 3,
        title: 't',
        url: 'u',
        author: 'a',
        date: '2026-05-15',
        recommendCount: 500,
        notRecommendCount: 0,
        commentCount: 0,
        viewCount: 0,
        thumbnailUrl: 'https://example.com/x.jpg',
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: best)),
        ),
      );
      expect(find.text('BEST'), findsOneWidget);
    });

    testWidgets('should NOT show BEST badge when recommendCount < 500', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.text('BEST'), findsNothing);
    });

    testWidgets('should show formatted timestamp when date is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost)),
        ),
      );
      expect(find.text(TimeAgo.formatDateString('2026-05-15')), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FeedCard(post: mediaPost, onTap: () => tapped = true),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FeedCard));
      expect(tapped, isTrue);
    });

    testWidgets('should render without error when isRead is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: mediaPost, isRead: true)),
        ),
      );
      expect(find.text('미디어 게시글 제목'), findsOneWidget);
    });
  });
}
