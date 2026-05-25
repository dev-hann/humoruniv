import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/providers/post_provider.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/presentation/screens/post_detail_screen.dart';
import 'package:integration_test/integration_test.dart';

final _testPosts = [
  const Post(
    id: 100,
    title: 'E2E 테스트 게시글 1',
    recommendCount: 42,
    url: '/board/read.html?table=pds&number=100',
  ),
  const Post(
    id: 101,
    title: 'E2E 테스트 게시글 2',
    recommendCount: 88,
    url: '/board/read.html?table=pds&number=101',
  ),
];

final _testPostDetail = PostDetail(
  id: 100,
  title: 'E2E 테스트 게시글 1',
  author: '테스트작성자',
  date: DateTime(2026, 5, 16),
  contentHtml: '<p>테스트 본문 내용입니다.</p>',
  contentBlocks: const [TextBlock('테스트 본문 내용입니다.')],
  imageUrls: const [],
  recommendCount: 42,
  notRecommendCount: 3,
  viewCount: 1500,
  commentCount: 5,
  comments: [
    Comment(
      id: 1,
      author: '댓글러',
      content: '웃기다',
      date: DateTime(2026, 5, 16),
      recommendCount: 10,
      isBest: true,
      replies: const [],
    ),
  ],
);

GoRouter _createTestRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/post',
      builder: (context, state) {
        final url = state.uri.queryParameters['url'] ?? '';
        return PostDetailScreen(postUrl: url);
      },
    ),
  ],
);

Widget _buildTestApp({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      title: 'HumorUniv',
      routerConfig: _createTestRouter(),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: home screen', () {
    testWidgets('should display app bar with HumorUniv title', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            bestPostsProvider.overrideWith((ref) async => Right(_testPosts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HumorUniv'), findsOneWidget);
    });

    testWidgets('should display post list from fake data', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            bestPostsProvider.overrideWith((ref) async => Right(_testPosts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('E2E 테스트 게시글 1'), findsOneWidget);
      expect(find.text('E2E 테스트 게시글 2'), findsOneWidget);
    });

    testWidgets('should show error state when provider fails', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            bestPostsProvider.overrideWith(
              (ref) async => const Left(ServerFailure('test error')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load posts'), findsOneWidget);
    });
  });

  group('E2E: post detail navigation', () {
    testWidgets('should navigate to post detail and display content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            bestPostsProvider.overrideWith((ref) async => Right(_testPosts)),
            postDetailProvider.overrideWith(
              (ref, url) async => Right(_testPostDetail),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final postCards = find.byType(ListTile);
      expect(postCards, findsWidgets);

      await tester.tap(postCards.first);
      await tester.pumpAndSettle();

      expect(find.text('테스트작성자'), findsOneWidget);
      expect(find.text('테스트 본문 내용입니다.'), findsOneWidget);
      expect(find.text('댓글러'), findsOneWidget);
    });

    testWidgets('should show error state on post detail failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          overrides: [
            bestPostsProvider.overrideWith((ref) async => Right(_testPosts)),
            postDetailProvider.overrideWith(
              (ref, url) async => const Left(ServerFailure('detail error')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Failed to load post'), findsWidgets);
    });
  });
}
