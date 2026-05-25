import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/presentation/providers/board_posts_provider.dart';
import 'package:humoruniv/presentation/widgets/board_post_card.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({required this.table, super.key});
  final String table;

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final _scrollController = ScrollController();
  SortOption _currentSort = SortOption.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(boardPostsParamsProvider.notifier).state = BoardPostsParams(
          table: widget.table,
          sort: _currentSort,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      ref.read(boardPostsProvider.notifier).fetchNextPage();
    }
  }

  void _changeSort(SortOption sort) {
    setState(() => _currentSort = sort);
    ref.read(boardPostsParamsProvider.notifier).state = BoardPostsParams(
      table: widget.table,
      sort: sort,
    );
    ref.invalidate(boardPostsProvider);
  }

  Future<void> _refresh() async {
    ref.invalidate(boardPostsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(boardPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('웃긴자료')),
      body: Column(
        children: [
          SortTabs(currentSort: _currentSort, onChanged: _changeSort),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: postsAsync.when(
                loading: () => const SkeletonPostList(),
                error: (_, __) => ListView(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('게시글을 불러올 수 없습니다.'),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                data: (state) {
                  if (state.posts.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(
                          height: 300,
                          child: Center(child: Text('게시글이 없습니다.')),
                        ),
                      ],
                    );
                  }
                  return _InfinitePostList(
                    posts: state.posts,
                    hasMore: state.hasMore,
                    isLoadingMore: state.isLoadingMore,
                    loadMoreError: state.loadMoreError,
                    scrollController: _scrollController,
                    onPostTap: (post) {
                      context.push(
                        '/post?url=${Uri.encodeComponent(post.url)}',
                      );
                    },
                    onRetry: () {
                      ref.read(boardPostsProvider.notifier).fetchNextPage();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SortTabs extends StatelessWidget {
  const SortTabs({
    required this.currentSort,
    required this.onChanged,
    super.key,
  });
  final SortOption currentSort;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: SortOption.values.map((sort) {
          final isSelected = sort == currentSort;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(sort.label),
              selected: isSelected,
              onSelected: (_) => onChanged(sort),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfinitePostList extends StatelessWidget {
  const _InfinitePostList({
    required this.posts,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.scrollController,
    required this.onPostTap,
    required this.onRetry,
  });
  final List<BoardPost> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;
  final ScrollController scrollController;
  final ValueChanged<BoardPost> onPostTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final extraCount = (hasMore || isLoadingMore || loadMoreError != null)
        ? 1
        : 0;

    return ListView.builder(
      controller: scrollController,
      itemCount: posts.length + extraCount,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          if (loadMoreError != null) {
            return LoadMoreError(message: '불러오기 실패', onRetry: onRetry);
          }
          if (isLoadingMore) {
            return const LoadingIndicator();
          }
          return const SizedBox.shrink();
        }
        return BoardPostCard(
          post: posts[index],
          onTap: () => onPostTap(posts[index]),
        );
      },
    );
  }
}
