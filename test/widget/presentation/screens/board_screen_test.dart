import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/presentation/screens/board_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

  const testPosts = [
    BoardPost(
      id: 1,
      title: 'Board Post 1',
      url: '/board/read.html?table=pds&number=1',
      author: 'user1',
      date: '2026-05-15',
      recommendCount: 100,
      notRecommendCount: 5,
      commentCount: 20,
      viewCount: 1000,
      thumbnailUrl: '',
    ),
    BoardPost(
      id: 2,
      title: 'Board Post 2',
      url: '/board/read.html?table=pds&number=2',
      author: 'user2',
      date: '2026-05-14',
      recommendCount: 50,
      notRecommendCount: 2,
      commentCount: 10,
      viewCount: 500,
      thumbnailUrl: '',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(SortOption.all);
  });

  setUp(() {
    mockRepository = MockPostRepository();
    if (di.sl.isRegistered<PostRepository>()) {
      di.sl.unregister<PostRepository>();
    }
    if (di.sl.isRegistered<GetBoardPosts>()) {
      di.sl.unregister<GetBoardPosts>();
    }
    di.sl.registerLazySingleton<PostRepository>(() => mockRepository);
    di.sl.registerLazySingleton(
      () => GetBoardPosts(repository: mockRepository),
    );
  });

  tearDown(di.sl.reset);

  testWidgets('should display board post titles when data loads', (
    tester,
  ) async {
    const result = BoardListResult(
      posts: testPosts,
      currentPage: 0,
      totalPage: 5,
    );
    when(
      () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
    ).thenAnswer((_) async => const Right(result));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Board Post 1'), findsOneWidget);
    expect(find.text('Board Post 2'), findsOneWidget);
  });

  testWidgets('should show loading indicator while fetching', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async =>
          const Right(BoardListResult(posts: [], currentPage: 0, totalPage: 1)),
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SkeletonPostList), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('should show error message when fetch fails', (tester) async {
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Error')));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글을 불러올 수 없습니다.'), findsOneWidget);
  });

  testWidgets('should display sort tabs', (tester) async {
    const result = BoardListResult(
      posts: testPosts,
      currentPage: 0,
      totalPage: 1,
    );
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Right(result));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('전체'), findsOneWidget);
    expect(find.text('일간'), findsOneWidget);
    expect(find.text('주간'), findsOneWidget);
  });

  testWidgets('should not show pagination when infinite scroll', (
    tester,
  ) async {
    const result = BoardListResult(
      posts: testPosts,
      currentPage: 0,
      totalPage: 5,
    );
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Right(result));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 5'), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('should show empty state when no posts', (tester) async {
    const result = BoardListResult(posts: [], currentPage: 0, totalPage: 0);
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Right(result));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BoardScreen(table: 'pds')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글이 없습니다.'), findsOneWidget);
  });
}
