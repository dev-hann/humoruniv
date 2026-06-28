import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/utils/time_ago.dart';
import 'package:humoruniv/core/widgets/atoms/feed_media.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

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

    PostDetail detailWith({
      List<String> imageUrls = const [],
      List<ContentBlock> blocks = const [],
      List<Comment> comments = const [],
      int commentCount = 0,
    }) => PostDetail(
      id: 1,
      title: '미디어 게시글 제목',
      author: '유머작가',
      date: DateTime(2026, 5, 15),
      contentHtml: '',
      contentBlocks: blocks,
      imageUrls: imageUrls,
      recommendCount: 42,
      notRecommendCount: 1,
      viewCount: 500,
      commentCount: commentCount,
      comments: comments,
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

    testWidgets(
      'should show FeedMedia (thumbnail) when no detail and thumbnail present',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: FeedCard(post: mediaPost)),
          ),
        );
        expect(find.byType(FeedMedia), findsOneWidget);
      },
    );

    testWidgets('should show title in caption for text post (no media)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedCard(post: textPost)),
        ),
      );
      expect(find.text('텍스트 전용 게시글'), findsOneWidget);
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

    testWidgets('should show full-size image from detail (not FeedMedia)', (
      tester,
    ) async {
      final detail = detailWith(
        imageUrls: const ['https://example.com/full.jpg'],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedCard(post: mediaPost, detail: detail),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(FeedMedia), findsNothing);
    });

    testWidgets('should show body text from detail', (tester) async {
      final detail = detailWith(blocks: const [TextBlock('상세 본문 미리보기 내용입니다.')]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedCard(post: textPost, detail: detail),
          ),
        ),
      );
      expect(find.text('상세 본문 미리보기 내용입니다.'), findsOneWidget);
    });

    testWidgets('should show comment preview from detail', (tester) async {
      final detail = detailWith(
        commentCount: 5,
        comments: [
          Comment(
            id: 1,
            author: '댓글러',
            content: '웃기다',
            date: DateTime(2026, 5, 15),
            recommendCount: 3,
            isBest: true,
            replies: const [],
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedCard(post: mediaPost, detail: detail),
          ),
        ),
      );
      expect(find.text('댓글 5개'), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
