import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:humoruniv/core/widgets/atoms/loading_indicator.dart';
import 'package:humoruniv/core/widgets/atoms/scroll_to_top_button.dart';
import 'package:humoruniv/core/widgets/molecules/feed_card.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/core/widgets/states/error_state_view.dart';
import 'package:humoruniv/core/widgets/states/skeleton_feed_card.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';
import 'package:humoruniv/presentation/providers/post_detail_provider.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';
import 'package:humoruniv/presentation/widgets/feed_comments_sheet.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';

class FeedCardItem extends ConsumerStatefulWidget {
  const FeedCardItem({required this.post, this.isRead = false, super.key});
  final BoardPost post;
  final bool isRead;

  @override
  ConsumerState<FeedCardItem> createState() => _FeedCardItemState();
}

class _FeedCardItemState extends ConsumerState<FeedCardItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncDetail = ref.watch(postDetailProvider(widget.post.url));
    final detail = asyncDetail.whenOrNull(
      data: (either) => either.fold((_) => null, (d) => d),
    );
    final hasImages = detail != null && detail.imageUrls.isNotEmpty;
    final hasComments = detail != null && detail.comments.isNotEmpty;
    final videoBlocks =
        detail?.contentBlocks.whereType<VideoBlock>().toList() ??
        const <VideoBlock>[];
    return FeedCard(
      post: widget.post,
      detail: detail,
      detailLoading: asyncDetail.isLoading,
      isRead: widget.isRead,
      onImageTap: !hasImages
          ? null
          : (i) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImageViewerScreen(
                  imageUrls: detail.imageUrls,
                  initialIndex: i,
                ),
                fullscreenDialog: true,
              ),
            ),
      onVideoTap: videoBlocks.isEmpty
          ? null
          : (i) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  body: Center(child: InlineVideoPlayer(block: videoBlocks[i])),
                ),
                fullscreenDialog: true,
              ),
            ),
      onCommentsTap: !hasComments
          ? null
          : () => showFeedCommentsSheet(
              context,
              detail.comments,
              detail.commentCount,
            ),
    );
  }
}

class FeedList extends StatefulWidget {
  const FeedList({
    required this.posts,
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.onLoadMore,
    this.onRetryLoadMore,
    this.readIds = const <int>{},
  });
  final List<BoardPost> posts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetryLoadMore;
  final Set<int> readIds;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  static const double _kShowScrollTopOffset = 600.0;

  final ScrollController _controller = ScrollController();
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      widget.onLoadMore?.call();
    }
    final shouldShow = position.pixels > _kShowScrollTopOffset;
    if (shouldShow != _showScrollTop) {
      setState(() => _showScrollTop = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ListView.builder(
        itemCount: 4,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, __) => const SkeletonFeedCard(),
      );
    }
    if (widget.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          ErrorStateView(
            message: widget.errorMessage ?? '게시글을 불러올 수 없습니다.',
            onRetry: widget.onRetry,
          ),
        ],
      );
    }
    if (widget.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyStateView(message: '게시글이 없습니다.'),
        ],
      );
    }

    final extra =
        (widget.hasMore || widget.isLoadingMore || widget.loadMoreError != null)
        ? 1
        : 0;

    return Stack(
      children: [
        ListView.builder(
          controller: _controller,
          itemCount: widget.posts.length + extra,
          itemBuilder: (context, index) {
            if (index == widget.posts.length) {
              if (widget.loadMoreError != null) {
                return LoadMoreError(
                  message: '불러오기 실패',
                  onRetry: widget.onRetryLoadMore ?? () {},
                );
              }
              if (widget.isLoadingMore) {
                return const LoadingIndicator();
              }
              return const SizedBox.shrink();
            }
            final post = widget.posts[index];
            return FeedCardItem(
              post: post,
              isRead: widget.readIds.contains(post.id),
            );
          },
        ),
        Positioned(
          right: AppSpacing.p16,
          bottom: AppSpacing.p16,
          child: ScrollToTopButton(
            visible: _showScrollTop,
            onTap: () {
              if (_controller.hasClients) {
                _controller.jumpTo(0);
              }
            },
          ),
        ),
      ],
    );
  }
}
