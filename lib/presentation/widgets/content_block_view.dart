import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';

class ContentBlockView extends StatelessWidget {
  const ContentBlockView({
    required this.block,
    required this.allImageUrls,
    super.key,
    this.imageIndex = 0,
    this.hideNsfw = true,
  });
  final ContentBlock block;
  final List<String> allImageUrls;
  final int imageIndex;
  final bool hideNsfw;

  bool get _isNsfwBlock {
    return (block is ImageBlock && (block as ImageBlock).isNsfw) ||
        (block is VideoBlock && (block as VideoBlock).isNsfw);
  }

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextBlock() => const SizedBox.shrink(),
      HtmlBlock() => const SizedBox.shrink(),
      ImageBlock() => Semantics(
        label: '이미지 ${imageIndex + 1} — 탭하여 전체 화면으로 보기',
        button: true,
        child: _CompactImageThumbnail(
          block: block as ImageBlock,
          allImageUrls: allImageUrls,
          hideNsfw: hideNsfw && _isNsfwBlock,
        ),
      ),
      VideoBlock() => Semantics(
        label: '동영상',
        button: true,
        child: _CompactVideoThumbnail(
          block: block as VideoBlock,
          hideNsfw: hideNsfw && _isNsfwBlock,
        ),
      ),
    };
  }
}

class _NsfwPlaceholder extends StatelessWidget {
  const _NsfwPlaceholder({required this.onTap});
  final VoidCallback onTap;

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
            maxHeight: 200,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline),
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

class _CompactImageThumbnail extends StatefulWidget {
  const _CompactImageThumbnail({
    required this.block,
    required this.allImageUrls,
    required this.hideNsfw,
  });
  final ImageBlock block;
  final List<String> allImageUrls;
  final bool hideNsfw;

  @override
  State<_CompactImageThumbnail> createState() => _CompactImageThumbnailState();
}

class _CompactImageThumbnailState extends State<_CompactImageThumbnail> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.hideNsfw && !_revealed) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: _NsfwPlaceholder(onTap: () => setState(() => _revealed = true)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Image.network(
              widget.block.url,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
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
              errorBuilder: (_, __, ___) => Container(
                height: 60,
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
    );
  }
}

class _CompactVideoThumbnail extends StatefulWidget {
  const _CompactVideoThumbnail({required this.block, required this.hideNsfw});
  final VideoBlock block;
  final bool hideNsfw;

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
        child: _NsfwPlaceholder(onTap: () => setState(() => _revealed = true)),
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
                body: Center(child: InlineVideoPlayer(block: widget.block)),
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
                    color: Colors.black.withValues(alpha: 0.4),
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
