import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/di/injection.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';

class BoardPostsState {
  const BoardPostsState({
    this.posts = const [],
    this.currentPage = 0,
    this.totalPage = 0,
    this.isLoadingMore = false,
    this.loadMoreError,
  });
  final List<BoardPost> posts;
  final int currentPage;
  final int totalPage;
  final bool isLoadingMore;
  final Object? loadMoreError;

  bool get hasMore => currentPage < totalPage - 1;

  BoardPostsState copyWith({
    List<BoardPost>? posts,
    int? currentPage,
    int? totalPage,
    bool? isLoadingMore,
    Failure? loadMoreError,
  }) {
    return BoardPostsState(
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}

class BoardPostsParams {
  const BoardPostsParams({required this.table, required this.sort});
  final String table;
  final SortOption sort;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPostsParams && table == other.table && sort == other.sort;

  @override
  int get hashCode => Object.hash(table, sort);
}

class BoardPostsNotifier extends AsyncNotifier<BoardPostsState> {
  @override
  Future<BoardPostsState> build() async {
    final arg = ref.watch(boardPostsParamsProvider);
    final result = await sl<GetBoardPosts>()(arg.table, 0, arg.sort);
    return result.fold(
      (failure) => throw failure,
      (data) => BoardPostsState(
        posts: data.posts,
        currentPage: data.currentPage,
        totalPage: data.totalPage,
      ),
    );
  }

  Future<void> fetchNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final arg = ref.read(boardPostsParamsProvider);
    final nextPage = current.currentPage + 1;
    final result = await sl<GetBoardPosts>()(arg.table, nextPage, arg.sort);

    result.fold(
      (failure) {
        final prev = state.value ?? current;
        state = AsyncData(
          prev.copyWith(isLoadingMore: false, loadMoreError: failure),
        );
      },
      (data) {
        final prev = state.value ?? current;
        final existingIds = prev.posts.map((p) => p.id).toSet();
        final fresh = data.posts
            .where((p) => !existingIds.contains(p.id))
            .toList();
        state = AsyncData(
          prev.copyWith(
            posts: [...prev.posts, ...fresh],
            currentPage: data.currentPage,
            totalPage: data.totalPage,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}

final boardPostsParamsProvider = StateProvider<BoardPostsParams>(
  (ref) => const BoardPostsParams(table: 'pds', sort: SortOption.all),
);

final boardPostsProvider =
    AsyncNotifierProvider<BoardPostsNotifier, BoardPostsState>(
      BoardPostsNotifier.new,
    );
