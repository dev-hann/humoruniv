import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_detail.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/screens/post_detail_screen.dart';

final _testDetail = PostDetail(
  id: 100,
  title: '테스트 게시글',
  author: '테스트작성자',
  date: DateTime(2026, 5, 16, 14, 30),
  contentHtml: '<p>본문 내용</p>',
  contentBlocks: const [TextBlock('첫 번째 문단'), TextBlock('두 번째 문단')],
  imageUrls: const [],
  recommendCount: 42,
  notRecommendCount: 3,
  viewCount: 1500,
  commentCount: 2,
  comments: [
    Comment(
      id: 1,
      author: '댓글러1',
      content: '웃기다',
      date: DateTime(2026, 5, 16),
      recommendCount: 10,
      isBest: true,
      replies: const [],
    ),
    Comment(
      id: 2,
      author: '댓글러2',
      content: '별로다',
      date: DateTime(2026, 5, 16),
      recommendCount: 1,
      isBest: false,
      replies: [
        Comment(
          id: 3,
          author: '대댓글러',
          content: '동의',
          date: DateTime(2026, 5, 16),
          recommendCount: 5,
          isBest: false,
          replies: const [],
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('should display title and author when data loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('테스트 게시글'), findsOneWidget);
    expect(find.text('테스트작성자'), findsOneWidget);
  });

  testWidgets('should display date formatted correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026-05-16'), findsNothing);
    expect(find.textContaining('전'), findsWidgets);
  });

  testWidgets('should display recommend, not-recommend, and view counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
  });

  testWidgets('should render TextBlock content blocks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 문단'), findsOneWidget);
    expect(find.text('두 번째 문단'), findsOneWidget);
  });

  testWidgets('should display comment section with count', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('댓글 (2)'), findsOneWidget);
  });

  testWidgets('should display comment authors and content', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('댓글러1'), findsOneWidget);
    expect(find.text('웃기다'), findsOneWidget);
    expect(find.text('댓글러2'), findsOneWidget);
    expect(find.text('별로다'), findsOneWidget);
  });

  testWidgets('should display BEST badge on best comments', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BEST'), findsOneWidget);
  });

  testWidgets('should display reply content with indent', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(_testDetail),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('대댓글러'), findsOneWidget);
    expect(find.text('동의'), findsOneWidget);
  });

  testWidgets('should show loading indicator while fetching', (tester) async {
    final completer = Completer<Either<Failure, PostDetail>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith((ref, url) => completer.future),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pump();

    expect(find.byType(SkeletonPostDetail), findsOneWidget);

    completer.complete(Right(_testDetail));
    await tester.pumpAndSettle();
  });

  testWidgets('should show error message when fetch fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => const Left(ServerFailure('HTTP 500')),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글을 불러올 수 없습니다.'), findsOneWidget);
  });

  testWidgets('should show retry button on error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => const Left(ServerFailure('HTTP 500')),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('should retry when Retry button is tapped', (tester) async {
    var callCount = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith((ref, url) async {
            callCount++;
            if (callCount == 1) {
              return const Left(ServerFailure('HTTP 500'));
            }
            return Right(
              PostDetail(
                id: 1,
                title: 'Retried Post',
                author: '작성자',
                date: DateTime(2026),
                contentHtml: '',
                contentBlocks: const [],
                imageUrls: const [],
                recommendCount: 0,
                notRecommendCount: 0,
                viewCount: 0,
                commentCount: 0,
                comments: const [],
              ),
            );
          }),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글을 불러올 수 없습니다.'), findsOneWidget);
    expect(callCount, equals(1));

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('Retried Post'), findsOneWidget);
    expect(callCount, equals(2));
  });

  testWidgets('should render ImageBlock from content blocks', (tester) async {
    final detailWithImage = PostDetail(
      id: 100,
      title: '이미지 테스트',
      author: '작성자',
      date: DateTime(2026, 5, 16),
      contentHtml: '',
      contentBlocks: const [ImageBlock(url: 'https://example.com/test.jpg')],
      imageUrls: const ['https://example.com/test.jpg'],
      recommendCount: 0,
      notRecommendCount: 0,
      viewCount: 0,
      commentCount: 0,
      comments: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postDetailProvider.overrideWith(
            (ref, url) async => Right(detailWithImage),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('should not render empty TextBlock', (tester) async {
    final detailWithEmpty = PostDetail(
      id: 100,
      title: '빈 텍스트',
      author: '작성자',
      date: DateTime(2026, 5, 16),
      contentHtml: '',
      contentBlocks: const [TextBlock(''), TextBlock('내용 있음')],
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
          postDetailProvider.overrideWith(
            (ref, url) async => Right(detailWithEmpty),
          ),
        ],
        child: const MaterialApp(home: PostDetailScreen(postUrl: '/test')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('내용 있음'), findsOneWidget);
  });
}
