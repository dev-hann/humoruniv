import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

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

  List<Override> overrides() => [
    feedPrefetchProvider.overrideWith((ref) async {}),
  ];

  List<BoardPost> samplePosts() => const [
    BoardPost(
      id: 1,
      title: '첫 번째 글',
      url: '/board/read.html?table=pds&number=1',
      author: '작성자1',
      date: '2026-05-15',
      recommendCount: 100,
      notRecommendCount: 0,
      commentCount: 5,
      viewCount: 1000,
      thumbnailUrl: '',
    ),
    BoardPost(
      id: 2,
      title: '두 번째 글',
      url: '/board/read.html?table=pds&number=2',
      author: '작성자2',
      date: '2026-05-15',
      recommendCount: 200,
      notRecommendCount: 0,
      commentCount: 8,
      viewCount: 2000,
      thumbnailUrl: '',
    ),
  ];

  testWidgets('should display post titles when data loads', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async => Right(
        BoardListResult(posts: samplePosts(), currentPage: 0, totalPage: 1),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('첫 번째 글'), findsOneWidget);
    expect(find.text('두 번째 글'), findsOneWidget);
  });

  testWidgets('should render a FeedCard for each post', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async => Right(
        BoardListResult(posts: samplePosts(), currentPage: 0, totalPage: 1),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FeedCard), findsNWidgets(2));
  });

  testWidgets('should show skeleton feed cards while fetching', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async =>
          const Right(BoardListResult(posts: [], currentPage: 0, totalPage: 0)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(SkeletonFeedCard), findsWidgets);

    await tester.pumpAndSettle();
  });

  testWidgets('should show empty message when no posts', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async =>
          const Right(BoardListResult(posts: [], currentPage: 0, totalPage: 0)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글이 없습니다.'), findsOneWidget);
  });

  testWidgets('should show error message when fetch fails', (tester) async {
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Network error')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('게시글을 불러올 수 없습니다.'), findsOneWidget);
  });

  testWidgets('should display AppBar with 웃긴자료 title', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async =>
          const Right(BoardListResult(posts: [], currentPage: 0, totalPage: 0)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final title = (appBar.title! as Text).data;
    expect(title, '웃긴자료');
  });

  testWidgets('should display settings gear action', (tester) async {
    when(() => mockRepository.getBoardPosts(any(), any(), any())).thenAnswer(
      (_) async =>
          const Right(BoardListResult(posts: [], currentPage: 0, totalPage: 0)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('설정'), findsOneWidget);
  });
}
