import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_durations.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';
import 'package:video_player/video_player.dart';

enum ContentBlockViewMode { full, compact }

class ContentBlockView extends StatelessWidget {
  final ContentBlock block;
  final List<String> allImageUrls;
  final int imageIndex;
  final ContentBlockViewMode mode;
  final bool hideNsfw;

  const ContentBlockView({
    super.key,
    required this.block,
    required this.allImageUrls,
    this.imageIndex = 0,
    this.mode = ContentBlockViewMode.full,
    this.hideNsfw = true,
  });

  bool get _isNsfwBlock {
    return (block is ImageBlock && (block as ImageBlock).isNsfw) ||
        (block is VideoBlock && (block as VideoBlock).isNsfw);
  }

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextBlock(:final text) => text.isEmpty || mode == ContentBlockViewMode.compact
          ? const SizedBox.shrink()
          : Padding(
              padding: AppSpacing.edgeOnlyBottom12,
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
      HtmlBlock(:final html) => mode == ContentBlockViewMode.compact
          ? const SizedBox.shrink()
          : Padding(
              padding: AppSpacing.edgeOnlyBottom12,
              child: HtmlWidget(
                html,
                textStyle: Theme.of(context).textTheme.bodyLarge,
                onTapUrl: (url) {
                  return false;
                },
              ),
            ),
      ImageBlock(:final url) => Semantics(
          label: '이미지 ${imageIndex + 1} — 탭하여 전체 화면으로 보기',
          button: true,
          child: _ImageBlockView(
            block: block as ImageBlock,
            allImageUrls: allImageUrls,
            imageIndex: imageIndex,
            mode: mode,
            hideNsfw: hideNsfw && _isNsfwBlock,
          ),
        ),
      VideoBlock(:final url, :final thumbnailUrl) => Semantics(
          label: '동영상',
          button: true,
          child: mode == ContentBlockViewMode.compact
              ? _CompactVideoThumbnail(
                  block: block as VideoBlock,
                  hideNsfw: hideNsfw && _isNsfwBlock,
                )
              : _InlineVideoPlayer(
                  block: block as VideoBlock,
                  hideNsfw: hideNsfw && _isNsfwBlock,
                ),
        ),
    };
  }
}

class _NsfwPlaceholder extends StatelessWidget {
  final bool isCompact;
  final VoidCallback onTap;

  const _NsfwPlaceholder({
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '민감한 콘텐츠 — 탭하여 표시',
      button: true,
      hint: '탭하면 콘텐츠를 표시합니다',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minHeight: AppSizes.minTouchTarget,
            maxHeight: isCompact ? 200 : AppSizes.imagePlaceholderHeight,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(isCompact ? 8 : 0),
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                '민감한 콘텐츠',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '탭하여 보기',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageBlockView extends StatefulWidget {
  final ImageBlock block;
  final List<String> allImageUrls;
  final int imageIndex;
  final ContentBlockViewMode mode;
  final bool hideNsfw;

  const _ImageBlockView({
    required this.block,
    required this.allImageUrls,
    required this.imageIndex,
    required this.mode,
    required this.hideNsfw,
  });

  @override
  State<_ImageBlockView> createState() => _ImageBlockViewState();
}

class _ImageBlockViewState extends State<_ImageBlockView> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.mode == ContentBlockViewMode.compact;

    if (widget.hideNsfw && !_revealed) {
      return Padding(
        padding: isCompact
            ? const EdgeInsets.only(top: 8, bottom: 8)
            : AppSpacing.edgeOnlyBottom8,
        child: _NsfwPlaceholder(
          isCompact: isCompact,
          onTap: () => setState(() => _revealed = true),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final idx = widget.allImageUrls.indexOf(widget.block.url);
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ImageViewerScreen(
              imageUrls: widget.allImageUrls,
              initialIndex: idx >= 0 ? idx : 0,
            ),
          ),
        );
      },
      child: Padding(
        padding: isCompact
            ? const EdgeInsets.only(top: 8, bottom: 8)
            : AppSpacing.edgeOnlyBottom8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCompact ? 8 : 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: isCompact ? 200 : double.infinity,
            ),
            child: Image.network(
              widget.block.url,
              fit: isCompact ? BoxFit.cover : BoxFit.contain,
              width: isCompact ? double.infinity : null,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: isCompact ? 200 : AppSizes.imagePlaceholderHeight,
                  color: AppColors.imagePlaceholder,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => GestureDetector(
                onTap: () {
                  final idx = widget.allImageUrls.indexOf(widget.block.url);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ImageViewerScreen(
                        imageUrls: widget.allImageUrls,
                        initialIndex: idx >= 0 ? idx : 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: isCompact ? 60 : AppSizes.minTouchTarget,
                  color: AppColors.imagePlaceholder,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactVideoThumbnail extends StatefulWidget {
  final VideoBlock block;
  final bool hideNsfw;

  const _CompactVideoThumbnail({
    required this.block,
    required this.hideNsfw,
  });

  @override
  State<_CompactVideoThumbnail> createState() => _CompactVideoThumbnailState();
}

class _CompactVideoThumbnailState extends State<_CompactVideoThumbnail> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.hideNsfw && !_revealed) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: _NsfwPlaceholder(
          isCompact: true,
          onTap: () => setState(() => _revealed = true),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(backgroundColor: Colors.black),
                body: Center(
                  child: _InlineVideoPlayer(
                    block: widget.block,
                    hideNsfw: false,
                  ),
                ),
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.block.thumbnailUrl != null)
                  Image.network(
                    widget.block.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                else
                  _buildPlaceholder(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      color: AppColors.imagePlaceholder,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white54, size: 32),
      ),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final VideoBlock block;
  final bool hideNsfw;

  const _InlineVideoPlayer({
    required this.block,
    required this.hideNsfw,
  });

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayButton = true;
  bool _revealed = false;
  bool _showControls = true;
  bool _isMuted = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.block.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller!.setLooping(true);
          _controller!.setVolume(0);
          _startHideTimer();
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted &&
          _isInitialized &&
          _controller != null &&
          _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _handleVideoTap() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls &&
        _isInitialized &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showPlayButton = true;
        _cancelHideTimer();
      } else {
        _controller!.play();
        _showPlayButton = false;
        _startHideTimer();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _enterFullscreen() {
    if (!mounted || _controller == null) return;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _FullscreenVideoScreen(
          block: widget.block,
          initialPosition: _controller!.value.position,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideNsfw && !_revealed) {
      return Padding(
        padding: AppSpacing.edgeOnlyBottom8,
        child: _NsfwPlaceholder(
          isCompact: false,
          onTap: () => setState(() => _revealed = true),
        ),
      );
    }

    final isGif = widget.block.isGifConversion;
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    return Padding(
      padding: AppSpacing.edgeOnlyBottom8,
      child: GestureDetector(
        onTap: _isInitialized ? _handleVideoTap : null,
        child: AspectRatio(
          aspectRatio:
              _isInitialized ? _controller!.value.aspectRatio : 16 / 9,
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_hasError)
                  _buildError()
                else if (_isInitialized)
                  ClipRect(
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                    ),
                  )
                else if (widget.block.thumbnailUrl != null)
                  Image.network(
                    widget.block.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _buildLoading(),
                  )
                else
                  _buildLoading(),
                if (!_hasError && !_isInitialized && !_showPlayButton)
                  const CircularProgressIndicator(color: Colors.white),
                if (isGif)
                  _buildGifOverlay()
                else
                  _buildControlsOverlay(position, duration),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGifOverlay() {
    if (!_showPlayButton) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _isInitialized ? _togglePlayPause : null,
      child: _buildCenterPlayIcon(),
    );
  }

  Widget _buildControlsOverlay(Duration position, Duration duration) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _isInitialized ? _handleVideoTap : null,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        IgnorePointer(
          ignoring: !_showControls,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: AppDurations.medium,
            curve: AppCurves.standard,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_showPlayButton)
                  Center(
                    child: GestureDetector(
                      onTap: _isInitialized ? _togglePlayPause : null,
                      child: _buildCenterPlayIcon(),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomControls(position, duration),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterPlayIcon() {
    final isPlaying =
        _isInitialized && _controller != null && _controller!.value.isPlaying;
    return Semantics(
      button: true,
      label: isPlaying ? '일시정지' : '재생',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: AppColors.imageViewerForeground,
        ),
      ),
    );
  }

  Widget _buildBottomControls(Duration position, Duration duration) {
    final isPlaying =
        _isInitialized && _controller != null && _controller!.value.isPlaying;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: 24, left: 4, right: 4, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isInitialized && _controller != null)
            VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          Row(
            children: [
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  tooltip: isPlaying ? '일시정지' : '재생',
                  icon: Icon(
                    isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: AppColors.imageViewerForeground,
                    size: AppSizes.iconLarge,
                  ),
                  onPressed: _isInitialized ? _togglePlayPause : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.minTouchTarget,
                    minHeight: AppSizes.minTouchTarget,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.imageViewerForeground,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  tooltip: _isMuted ? '음소거 해제' : '음소거',
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: AppColors.imageViewerForeground,
                    size: AppSizes.iconLarge,
                  ),
                  onPressed: _isInitialized ? _toggleMute : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.minTouchTarget,
                    minHeight: AppSizes.minTouchTarget,
                  ),
                ),
              ),
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  tooltip: '전체 화면',
                  icon: Icon(
                    Icons.fullscreen,
                    color: AppColors.imageViewerForeground,
                    size: AppSizes.iconLarge,
                  ),
                  onPressed: _enterFullscreen,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.minTouchTarget,
                    minHeight: AppSizes.minTouchTarget,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: AppColors.imagePlaceholder,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: AppColors.imagePlaceholder,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 32),
            SizedBox(height: 8),
            Text('동영상을 불러올 수 없습니다',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _FullscreenVideoScreen extends StatefulWidget {
  final VideoBlock block;
  final Duration initialPosition;

  const _FullscreenVideoScreen({
    required this.block,
    required this.initialPosition,
  });

  @override
  State<_FullscreenVideoScreen> createState() => _FullscreenVideoScreenState();
}

class _FullscreenVideoScreenState extends State<_FullscreenVideoScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showPlayButton = true;
  bool _showControls = true;
  bool _isMuted = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.block.url))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
              _controller!.setLooping(true);
              _controller!.setVolume(0);
              if (widget.initialPosition > Duration.zero) {
                _controller!.seekTo(widget.initialPosition);
              }
              _startHideTimer();
            }
          }).catchError((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted &&
          _isInitialized &&
          _controller != null &&
          _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _handleVideoTap() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls &&
        _isInitialized &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showPlayButton = true;
        _cancelHideTimer();
      } else {
        _controller!.play();
        _showPlayButton = false;
        _startHideTimer();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _isInitialized ? _handleVideoTap : null,
            child: Center(
              child: AspectRatio(
                aspectRatio:
                    _isInitialized ? _controller!.value.aspectRatio : 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_hasError)
                        _buildError()
                      else if (_isInitialized)
                        ClipRect(
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.size.width,
                                height: _controller!.value.size.height,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      IgnorePointer(
                        ignoring: !_showControls,
                        child: AnimatedOpacity(
                          opacity: _showControls ? 1.0 : 0.0,
                          duration: AppDurations.medium,
                          curve: AppCurves.standard,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_showPlayButton)
                                Center(
                                  child: GestureDetector(
                                    onTap: _isInitialized
                                        ? _togglePlayPause
                                        : null,
                                    child: _buildCenterPlayIcon(),
                                  ),
                                ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _buildBottomControls(position, duration),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                child: _buildTopBar(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayIcon() {
    final isPlaying =
        _isInitialized && _controller != null && _controller!.value.isPlaying;
    return Semantics(
      button: true,
      label: isPlaying ? '일시정지' : '재생',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: AppColors.imageViewerForeground,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 4,
        right: 4,
        bottom: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.minTouchTarget,
            height: AppSizes.minTouchTarget,
            child: IconButton(
              tooltip: '닫기',
              icon: Icon(
                Icons.close,
                color: AppColors.imageViewerForeground,
                size: AppSizes.iconLarge,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouchTarget,
                minHeight: AppSizes.minTouchTarget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(Duration position, Duration duration) {
    final isPlaying =
        _isInitialized && _controller != null && _controller!.value.isPlaying;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 4,
        right: 4,
        bottom: MediaQuery.of(context).padding.bottom + 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isInitialized && _controller != null)
            VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Colors.white.withOpacity(0.3),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          Row(
            children: [
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  tooltip: isPlaying ? '일시정지' : '재생',
                  icon: Icon(
                    isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: AppColors.imageViewerForeground,
                    size: AppSizes.iconLarge,
                  ),
                  onPressed: _isInitialized ? _togglePlayPause : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.minTouchTarget,
                    minHeight: AppSizes.minTouchTarget,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.imageViewerForeground,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  tooltip: _isMuted ? '음소거 해제' : '음소거',
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: AppColors.imageViewerForeground,
                    size: AppSizes.iconLarge,
                  ),
                  onPressed: _isInitialized ? _toggleMute : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.minTouchTarget,
                    minHeight: AppSizes.minTouchTarget,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: AppColors.imagePlaceholder,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 32),
            SizedBox(height: 8),
            Text('동영상을 불러올 수 없습니다',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
