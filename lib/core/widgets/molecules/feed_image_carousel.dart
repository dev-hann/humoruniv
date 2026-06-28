import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

class FeedImageCarousel extends StatefulWidget {
  const FeedImageCarousel({
    required this.imageUrls,
    this.videoBlocks = const [],
    this.onImageTap,
    this.onVideoTap,
    super.key,
  });
  final List<String> imageUrls;
  final List<VideoBlock> videoBlocks;
  final ValueChanged<int>? onImageTap;
  final ValueChanged<int>? onVideoTap;

  @override
  State<FeedImageCarousel> createState() => _FeedImageCarouselState();
}

class _FeedImageCarouselState extends State<FeedImageCarousel> {
  final PageController _controller = PageController();
  int _page = 0;
  static final Map<String, double> _aspectCache = {};

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
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
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
    final url = _currentMediaUrl;
    final aspect = (url != null ? _aspectCache[url] : null) ?? 1.0;
    final height = (screenW / aspect).clamp(120.0, AppSizes.feedMediaMaxHeight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: height,
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
                  return _buildImagePage(index);
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

  Widget _buildImagePage(int index) {
    return GestureDetector(
      onTap: widget.onImageTap == null ? null : () => widget.onImageTap!(index),
      child: Image.network(
        widget.imageUrls[index],
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: AppSizes.iconLarge * 2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPage(int index) {
    final video = widget.videoBlocks[index];
    return GestureDetector(
      onTap: widget.onVideoTap == null ? null : () => widget.onVideoTap!(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (video.thumbnailUrl != null)
            Image.network(
              video.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: Colors.grey[900]!),
            )
          else
            ColoredBox(color: Colors.grey[900]!),
          Center(
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
        ],
      ),
    );
  }
}
