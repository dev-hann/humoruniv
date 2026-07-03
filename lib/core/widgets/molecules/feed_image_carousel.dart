import 'package:flutter/material.dart';

import 'package:humoruniv/core/providers/feed_video_playback_provider.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/widgets/molecules/feed_media_sizing.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

class FeedImageCarousel extends StatefulWidget {
  const FeedImageCarousel({
    required this.imageUrls,
    required this.postId,
    this.videoBlocks = const [],
    this.onImageTap,
    this.imageProviderBuilder,
    super.key,
  });
  final List<String> imageUrls;
  final int postId;
  final List<VideoBlock> videoBlocks;
  final ValueChanged<int>? onImageTap;
  final ImageProvider Function(String url)? imageProviderBuilder;

  @override
  State<FeedImageCarousel> createState() => _FeedImageCarouselState();
}

class _FeedImageCarouselState extends State<FeedImageCarousel> {
  final PageController _controller = PageController();
  int _page = 0;
  int? _expandedVideoIndex;
  static final Map<String, double> _aspectCache = {};

  ImageProvider _providerFor(String url) =>
      widget.imageProviderBuilder?.call(url) ?? NetworkImage(url);

  int get _totalCount => widget.imageUrls.length + widget.videoBlocks.length;

  String? get _currentMediaUrl {
    if (_page < widget.imageUrls.length) {
      return widget.imageUrls[_page];
    }
    final vi = _page - widget.imageUrls.length;
    if (vi < widget.videoBlocks.length) {
      return widget.videoBlocks[vi].thumbnailUrl;
    }
    return null;
  }

  double _aspectFor(String? url) =>
      (url != null ? _aspectCache[url] : null) ?? 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAll());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measureAll() {
    for (final url in widget.imageUrls) {
      _measure(url);
    }
    for (final v in widget.videoBlocks) {
      if (v.thumbnailUrl != null) _measure(v.thumbnailUrl!);
    }
  }

  void _measure(String url) {
    if (_aspectCache.containsKey(url)) return;
    final stream = _providerFor(url).resolve(ImageConfiguration.empty);
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!mounted || listener == null) return;
        setState(() {
          _aspectCache[url] =
              info.image.width.toDouble() / info.image.height.toDouble();
        });
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (listener != null) stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalCount;
    final multiple = total > 1;
    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;
    final sizing = FeedMediaSizing.resolve(
      aspect: _aspectFor(_currentMediaUrl),
      screenW: screenW,
      screenH: screenH,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: sizing.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                if (index < widget.imageUrls.length) {
                  return _buildImagePage(index, screenW, screenH);
                }
                return _buildVideoPage(index - widget.imageUrls.length);
              },
            ),
          ),
          if (multiple)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_page + 1}/$total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePage(int index, double screenW, double screenH) {
    final url = widget.imageUrls[index];
    return _FeedCarouselImagePage(
      image: _providerFor(url),
      aspect: _aspectFor(url),
      screenW: screenW,
      screenH: screenH,
      onTap: widget.onImageTap == null ? null : () => widget.onImageTap!(index),
    );
  }

  Widget _buildVideoPage(int index) {
    if (index == _expandedVideoIndex) {
      return InlineVideoPlayer(
        block: widget.videoBlocks[index],
        autoplay: true,
        videoId: VideoId(postId: widget.postId, blockIndex: index),
      );
    }
    final video = widget.videoBlocks[index];
    return Stack(
      fit: StackFit.expand,
      children: [
        if (video.thumbnailUrl != null)
          Image(
            image: _providerFor(video.thumbnailUrl!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => ColoredBox(color: Colors.grey[900]!),
          )
        else
          ColoredBox(color: Colors.grey[900]!),
        Center(
          child: Semantics(
            label: '재생',
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expandedVideoIndex = index),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedCarouselImagePage extends StatefulWidget {
  const _FeedCarouselImagePage({
    required this.image,
    required this.aspect,
    required this.screenW,
    required this.screenH,
    this.onTap,
  });
  final ImageProvider image;
  final double aspect;
  final double screenW;
  final double screenH;
  final VoidCallback? onTap;

  @override
  State<_FeedCarouselImagePage> createState() => _FeedCarouselImagePageState();
}

class _FeedCarouselImagePageState extends State<_FeedCarouselImagePage> {
  final ScrollController _scrollController = ScrollController();
  bool _atBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 8;
    if (atBottom != _atBottom) {
      setState(() => _atBottom = atBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = FeedMediaSizing.resolve(
      aspect: widget.aspect,
      screenW: widget.screenW,
      screenH: widget.screenH,
    );
    final image = Image(
      image: widget.image,
      width: widget.screenW,
      height: widget.screenW / widget.aspect,
      fit: BoxFit.fitWidth,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: AppSizes.iconLarge * 2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
    return GestureDetector(
      onTap: widget.onTap,
      child: sizing.needsScroll
          ? Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: image,
                ),
                if (!_atBottom)
                  Positioned(
                    key: const ValueKey('feed_media_scroll_fade'),
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 48,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : image,
    );
  }
}
