import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_sizes.dart';

class FeedImageCarousel extends StatefulWidget {
  const FeedImageCarousel({
    required this.imageUrls,
    this.onImageTap,
    this.height,
    super.key,
  });
  final List<String> imageUrls;
  final ValueChanged<int>? onImageTap;
  final double? height;

  @override
  State<FeedImageCarousel> createState() => _FeedImageCarouselState();
}

class _FeedImageCarouselState extends State<FeedImageCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final multiple = urls.length > 1;
    final height = widget.height ?? AppSizes.feedMediaMaxHeight;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: widget.onImageTap == null
                      ? null
                      : () => widget.onImageTap!(index),
                  child: Image.network(
                    urls[index],
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
                  '${_page + 1}/${urls.length}',
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
}
