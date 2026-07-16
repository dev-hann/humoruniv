import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart' as di;
import 'package:humoruniv/domain/entities/board_list_result.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/presentation/providers/board_posts_provider.dart';
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

  group('BoardPostsState', () {
    test('copyWith updates posts only', () {
      const state = BoardPostsState(currentPage: 2, totalPage: 5);
      final copied = state.copyWith(posts: []);

      expect(copied.posts, isEmpty);
      expect(copied.currentPage, 2);
      expect(copied.totalPage, 5);
    });

    test('copyWith clears loadMoreError', () {
      const state = BoardPostsState(loadMoreError: ServerFailure('err'));
      final copied = state.copyWith();

      expect(copied.loadMoreError, isNull);
    });

    test('hasMore is false when on last page', () {
      const state = BoardPostsState(currentPage: 4, totalPage: 5);

      expect(state.hasMore, isFalse);
    });

    test('hasMore is false with zero pages', () {
      const state = BoardPostsState();

      expect(state.hasMore, isFalse);
    });

    test('default state has expected values', () {
      const state = BoardPostsState();

      expect(state.posts, isEmpty);
      expect(state.currentPage, 0);
      expect(state.totalPage, 0);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isNull);
    });
  });

  group('BoardPostsParams', () {
    test('equal when table and sort match', () {
      const a = BoardPostsParams(table: 'pds', sort: SortOption.all);
      const b = BoardPostsParams(table: 'pds', sort: SortOption.all);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when table differs', () {
      const a = BoardPostsParams(table: 'pds', sort: SortOption.all);
      const b = BoardPostsParams(table: 'joke', sort: SortOption.all);

      expect(a, isNot(equals(b)));
    });

    test('not equal when sort differs', () {
      const a = BoardPostsParams(table: 'pds', sort: SortOption.all);
      const b = BoardPostsParams(table: 'pds', sort: SortOption.day);

      expect(a, isNot(equals(b)));
    });
  });

  group('boardPostsParamsProvider', () {
    test('default value is pds with SortOption.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final params = container.read(boardPostsParamsProvider);

      expect(params.table, 'pds');
      expect(params.sort, SortOption.all);
    });
  });

  test('should load initial page with posts', () async {
    const result = BoardListResult(
      posts: [
        BoardPost(
          id: 1,
          title: 'Post 1',
          url: '/board/read.html?table=pds&number=1',
          author: 'user',
          date: '2026-05-15',
          recommendCount: 50,
          notRecommendCount: 1,
          commentCount: 10,
          viewCount: 500,
          thumbnailUrl: '',
        ),
      ],
      currentPage: 0,
      totalPage: 5,
    );
    when(
      () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
    ).thenAnswer((_) async => const Right(result));

    final container = ProviderContainer(
      overrides: [
        boardPostsParamsProvider.overrideWith(
          (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
        ),
      ],
    );
    addTearDown(container.dispose);

    final asyncValue = await container.read(boardPostsProvider.future);
    expect(asyncValue.posts, hasLength(1));
    expect(asyncValue.posts.first.title, 'Post 1');
    expect(asyncValue.currentPage, 0);
    expect(asyncValue.totalPage, 5);
    expect(asyncValue.hasMore, isTrue);
  });

  test('should be in error state when fetch fails', () async {
    when(
      () => mockRepository.getBoardPosts(any(), any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Error')));

    final container = ProviderContainer(
      overrides: [
        boardPostsParamsProvider.overrideWith(
          (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(boardPostsProvider.future),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('fetchNextPage should append posts', () async {
    const page0 = BoardListResult(
      posts: [
        BoardPost(
          id: 1,
          title: 'Post 1',
          url: '/board/read.html?table=pds&number=1',
          author: 'user',
          date: '2026-05-15',
          recommendCount: 50,
          notRecommendCount: 1,
          commentCount: 10,
          viewCount: 500,
          thumbnailUrl: '',
        ),
      ],
      currentPage: 0,
      totalPage: 3,
    );
    const page1 = BoardListResult(
      posts: [
        BoardPost(
          id: 2,
          title: 'Post 2',
          url: '/board/read.html?table=pds&number=2',
          author: 'user2',
          date: '2026-05-16',
          recommendCount: 30,
          notRecommendCount: 0,
          commentCount: 5,
          viewCount: 200,
          thumbnailUrl: '',
        ),
      ],
      currentPage: 1,
      totalPage: 3,
    );
    when(
      () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
    ).thenAnswer((_) async => const Right(page0));
    when(
      () => mockRepository.getBoardPosts('pds', 1, SortOption.all),
    ).thenAnswer((_) async => const Right(page1));

    final container = ProviderContainer(
      overrides: [
        boardPostsParamsProvider.overrideWith(
          (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(boardPostsProvider.future);
    await container.read(boardPostsProvider.notifier).fetchNextPage();

    final state = container.read(boardPostsProvider).value!;
    expect(state.posts, hasLength(2));
    expect(state.posts[0].title, 'Post 1');
    expect(state.posts[1].title, 'Post 2');
    expect(state.currentPage, 1);
    expect(state.hasMore, isTrue);
  });

  test('fetchNextPage should not fetch when hasMore is false', () async {
    const result = BoardListResult(
      posts: [
        BoardPost(
          id: 1,
          title: 'Post 1',
          url: '/board/read.html?table=pds&number=1',
          author: 'user',
          date: '2026-05-15',
          recommendCount: 50,
          notRecommendCount: 1,
          commentCount: 10,
          viewCount: 500,
          thumbnailUrl: '',
        ),
      ],
      currentPage: 0,
      totalPage: 1,
    );
    when(
      () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
    ).thenAnswer((_) async => const Right(result));

    final container = ProviderContainer(
      overrides: [
        boardPostsParamsProvider.overrideWith(
          (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(boardPostsProvider.future);
    await container.read(boardPostsProvider.notifier).fetchNextPage();

    verifyNever(() => mockRepository.getBoardPosts('pds', 1, SortOption.all));
    final state = container.read(boardPostsProvider).value!;
    expect(state.posts, hasLength(1));
    expect(state.hasMore, isFalse);
  });

  test('fetchNextPage should preserve posts on error', () async {
    const page0 = BoardListResult(
      posts: [
        BoardPost(
          id: 1,
          title: 'Post 1',
          url: '/board/read.html?table=pds&number=1',
          author: 'user',
          date: '2026-05-15',
          recommendCount: 50,
          notRecommendCount: 1,
          commentCount: 10,
          viewCount: 500,
          thumbnailUrl: '',
        ),
      ],
      currentPage: 0,
      totalPage: 3,
    );
    when(
      () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
    ).thenAnswer((_) async => const Right(page0));
    when(
      () => mockRepository.getBoardPosts('pds', 1, SortOption.all),
    ).thenAnswer((_) async => const Left(ServerFailure('Network error')));

    final container = ProviderContainer(
      overrides: [
        boardPostsParamsProvider.overrideWith(
          (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(boardPostsProvider.future);
    await container.read(boardPostsProvider.notifier).fetchNextPage();

    final state = container.read(boardPostsProvider).value!;
    expect(state.posts, hasLength(1));
    expect(state.loadMoreError, isNotNull);
    expect(state.isLoadingMore, isFalse);
  });

  test(
    'fetchNextPage should drop only already-present ids and keep new ones',
    () async {
      const page0 = BoardListResult(
        posts: [
          BoardPost(
            id: 1,
            title: 'Post 1',
            url: '/board/read.html?table=pds&number=1',
            author: 'user',
            date: '2026-05-15',
            recommendCount: 50,
            notRecommendCount: 1,
            commentCount: 10,
            viewCount: 500,
            thumbnailUrl: '',
          ),
        ],
        currentPage: 0,
        totalPage: 3,
      );
      const page1 = BoardListResult(
        posts: [
          BoardPost(
            id: 1,
            title: 'Post 1 dup',
            url: '/board/read.html?table=pds&number=1',
            author: 'user',
            date: '2026-05-15',
            recommendCount: 50,
            notRecommendCount: 1,
            commentCount: 10,
            viewCount: 500,
            thumbnailUrl: '',
          ),
          BoardPost(
            id: 2,
            title: 'Post 2 new',
            url: '/board/read.html?table=pds&number=2',
            author: 'user2',
            date: '2026-05-16',
            recommendCount: 30,
            notRecommendCount: 0,
            commentCount: 5,
            viewCount: 200,
            thumbnailUrl: '',
          ),
        ],
        currentPage: 1,
        totalPage: 3,
      );
      when(
        () => mockRepository.getBoardPosts('pds', 0, SortOption.all),
      ).thenAnswer((_) async => const Right(page0));
      when(
        () => mockRepository.getBoardPosts('pds', 1, SortOption.all),
      ).thenAnswer((_) async => const Right(page1));

      final container = ProviderContainer(
        overrides: [
          boardPostsParamsProvider.overrideWith(
            (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(boardPostsProvider.future);
      await container.read(boardPostsProvider.notifier).fetchNextPage();

      final state = container.read(boardPostsProvider).value!;
      expect(
        state.posts,
        hasLength(2),
        reason: 'duplicate id should be dropped, new id kept',
      );
      expect(state.posts.map((p) => p.id), [1, 2]);
      expect(
        state.currentPage,
        1,
        reason: 'page pointer must still advance to avoid refetch loop',
      );
      expect(state.hasMore, isTrue);
    },
  );
}
