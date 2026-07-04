import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/long_image.dart';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.imageUrls,
    this.initialIndex = 0,
    super.key,
  });
  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late final PhotoViewScaleStateController _scaleStateController;
  int _currentIndex = 0;
  bool _isZoomed = false;
  double _dragY = 0;
  final Map<String, double> _aspects = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _scaleStateController = PhotoViewScaleStateController()
      ..outputScaleStateStream.listen((state) {
        final zoomed = state != PhotoViewScaleState.zoomedOut;
        if (zoomed != _isZoomed) {
          setState(() {
            _isZoomed = zoomed;
            if (zoomed) _dragY = 0;
          });
        }
      });
    for (final url in widget.imageUrls) {
      _resolveAspect(url);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  void _resolveAspect(String url) {
    if (_aspects.containsKey(url)) return;
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!mounted || listener == null) return;
        final aspect =
            info.image.width.toDouble() / info.image.height.toDouble();
        setState(() => _aspects[url] = aspect);
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (listener != null) stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
  }

  double get _dismissThreshold => MediaQuery.sizeOf(context).height * 0.25;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isZoomed) return;
    if (details.delta.dy > 0) {
      setState(() => _dragY += details.delta.dy);
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragY > _dismissThreshold) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragY = 0);
    }
  }

  bool _isLongImage(int index) {
    if (index < 0 || index >= widget.imageUrls.length) return false;
    final size = MediaQuery.sizeOf(context);
    final viewportAspect = size.width / size.height;
    final imageAspect = _aspects[widget.imageUrls[index]];
    if (imageAspect == null) return false;
    return LongImage.fitWidthScale(
          imageAspect: imageAspect,
          viewportAspect: viewportAspect,
        ) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    final dismissProgress = (_dragY / _dismissThreshold).clamp(0.0, 1.0);
    final multiple = widget.imageUrls.length > 1;
    final currentIsLong = _isLongImage(_currentIndex);

    final gallery = Transform.translate(
      offset: Offset(0, _dragY),
      child: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        onPageChanged: (index) => setState(() {
          _currentIndex = index;
          _dragY = 0;
        }),
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        builder: (context, index) {
          final size = MediaQuery.sizeOf(context);
          final viewportAspect = size.width / size.height;
          final imageAspect = _aspects[widget.imageUrls[index]];
          final fitScale = imageAspect == null
              ? null
              : LongImage.fitWidthScale(
                  imageAspect: imageAspect,
                  viewportAspect: viewportAspect,
                );
          final isLong = fitScale != null;
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            initialScale: isLong
                ? PhotoViewComputedScale.contained * fitScale
                : PhotoViewComputedScale.contained,
            minScale: isLong
                ? PhotoViewComputedScale.contained * fitScale
                : PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3,
            basePosition: isLong ? Alignment.topCenter : Alignment.center,
            scaleStateController: _scaleStateController,
            filterQuality: FilterQuality.medium,
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: AppColors.imageViewerForeground,
          ),
        ),
      ),
    );

    // 줌 상태이거나 긴 이미지(세로 팬으로 읽기)에서는 photo_view가 제스처를 점유;
    // 일반 이미지 1x일 때만 아래로 드래그해 닫기 허용.
    final galleryWithDismiss = (_isZoomed || currentIsLong)
        ? gallery
        : GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: gallery,
          );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(1 - dismissProgress * 0.6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.imageViewerForeground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          galleryWithDismiss,
          if (multiple)
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
      ),
    );
  }
}
