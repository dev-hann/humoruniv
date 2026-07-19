import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/widgets/atoms/retryable_network_image.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';

class ContentBlockView extends StatelessWidget {
  const ContentBlockView({
    required this.block,
    required this.allImageUrls,
    super.key,
    this.imageIndex = 0,
  });
  final ContentBlock block;
  final List<String> allImageUrls;
  final int imageIndex;

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
        ),
      ),
      VideoBlock() => Semantics(
        label: '동영상',
        button: true,
        child: _CompactVideoThumbnail(block: block as VideoBlock),
      ),
    };
  }
}

class _CompactImageThumbnail extends StatelessWidget {
  const _CompactImageThumbnail({
    required this.block,
    required this.allImageUrls,
  });
  final ImageBlock block;
  final List<String> allImageUrls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () {
          final idx = allImageUrls.indexOf(block.url);
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ImageViewerScreen(
                imageUrls: allImageUrls,
                initialIndex: idx >= 0 ? idx : 0,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: RetryableNetworkImage(
              imageUrl: block.url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactVideoThumbnail extends StatelessWidget {
  const _CompactVideoThumbnail({required this.block});
  final VideoBlock block;

  @override
  Widget build(BuildContext context) {
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
                body: Center(child: InlineVideoPlayer(block: block)),
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
                if (block.thumbnailUrl != null)
                  RetryableNetworkImage(
                    imageUrl: block.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
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
