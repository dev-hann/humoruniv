import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/utils/long_image.dart';

/// Full-screen image viewer.
///
/// Multiple images are paged horizontally with a [PageView]. Each page picks
/// its interaction model from the image aspect ratio:
///   * **Long** (taller-than-viewport at fit-width) images render in a vertical
///     [SingleChildScrollView] so they can be read by scrolling down — no
///     pinch-zoom, native momentum scrolling, no gesture conflict.
///   * **Normal** images render in an [InteractiveViewer] for pinch-zoom/pan.
///
/// This deliberately avoids `photo_view`: its scale gesture recognizer fought
/// the horizontal [PageView] and stuttered on long images.
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    required this.imageUrls,
    this.initialIndex = 0,
    this.knownAspects,
    super.key,
  });

  /// Image URLs to display. A single item still works (no paging indicator).
  final List<String> imageUrls;

  /// Page shown first.
  final int initialIndex;

  /// Optionally pre-resolved width/height aspects keyed by URL. Callers that
  /// already know image dimensions (e.g. the feed carousel, which sizes by
  /// aspect) may pass them to skip re-resolving here. When absent for a URL,
  /// the viewer resolves it itself.
  final Map<String, double>? knownAspects;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late final TransformationController _transformController;

  int _currentIndex = 0;
  bool _isZoomed = false;
  double _dragY = 0;
  final Map<String, double> _aspects = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformController = TransformationController()
      ..addListener(_onTransformChanged);
    if (widget.knownAspects != null) {
      _aspects.addAll(widget.knownAspects!);
    }
    for (final url in widget.imageUrls) {
      _resolveAspect(url);
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _transformController.value.getMaxScaleOnAxis() > 1.0;
    if (zoomed != _isZoomed) {
      setState(() {
        _isZoomed = zoomed;
        if (zoomed) _dragY = 0;
      });
    }
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
      onError: (Object _, StackTrace? __) {
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
    // Only allow the swipe-down-to-dismiss on a normal image at 1x. Long images
    // use a vertical ScrollView; zoomed images pan via InteractiveViewer.
    final allowDismiss = !currentIsLong && !_isZoomed;

    final pageView = PageView.builder(
      controller: _pageController,
      itemCount: widget.imageUrls.length,
      onPageChanged: (index) => setState(() {
        _currentIndex = index;
        _dragY = 0;
        _transformController.value = Matrix4.identity();
      }),
      itemBuilder: (context, index) => _buildPage(index),
    );

    final body = allowDismiss
        ? GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            behavior: HitTestBehavior.opaque,
            child: pageView,
          )
        : pageView;

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
          Transform.translate(offset: Offset(0, _dragY), child: body),
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

  Widget _buildPage(int index) {
    final url = widget.imageUrls[index];
    if (_isLongImage(index)) {
      return SingleChildScrollView(
        child: Image.network(
          url,
          width: MediaQuery.sizeOf(context).width,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
      );
    }
    return InteractiveViewer(
      transformationController: _transformController,
      maxScale: 4,
      // Pan only once zoomed in; at 1x, single-finger drags fall through to
      // the swipe-down-to-dismiss handler (and horizontal paging).
      panEnabled: _isZoomed,
      child: Center(
        child: Image.network(
          url,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
      ),
    );
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? event,
  ) {
    if (event == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
        color: AppColors.imageViewerForeground,
      ),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: AppColors.imageViewerForeground,
        size: 48,
      ),
    );
  }
}
