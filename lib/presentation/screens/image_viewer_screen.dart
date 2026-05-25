import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.imageUrls,
    super.key,
    this.initialIndex = 0,
  });
  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  int _currentIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.imageViewerBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.imageViewerForeground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: widget.imageUrls.length == 1
          ? _buildSingleImage()
          : _buildPageView(),
    );
  }

  Widget _buildSingleImage() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Image.network(
          widget.imageUrls.first,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                    : null,
                color: AppColors.imageViewerForeground,
              ),
            );
          },
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(
              Icons.broken_image,
              color: AppColors.imageViewerForegroundMuted,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        color: AppColors.imageViewerForeground,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.imageViewerForegroundMuted,
                      size: 64,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: AppSizes.imageViewerIndicatorBottom,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: AppSpacing.edgeH12V6,
              decoration: const BoxDecoration(
                color: AppColors.imageViewerOverlay,
                borderRadius: AppRadius.borderRadiusXl,
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: AppColors.imageViewerForeground,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
