import 'package:meta/meta.dart';

sealed class ContentBlock {
  const ContentBlock();
}

@immutable
class TextBlock extends ContentBlock {
  final String text;

  const TextBlock(this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextBlock && runtimeType == other.runtimeType && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

@immutable
class ImageBlock extends ContentBlock {
  final String url;
  final String? thumbnailUrl;
  final bool isNsfw;

  const ImageBlock({required this.url, this.thumbnailUrl, this.isNsfw = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageBlock &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          thumbnailUrl == other.thumbnailUrl &&
          isNsfw == other.isNsfw;

  @override
  int get hashCode => Object.hash(url, thumbnailUrl, isNsfw);
}

@immutable
class VideoBlock extends ContentBlock {
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final bool isGifConversion;
  final bool isNsfw;

  const VideoBlock({
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.isGifConversion = false,
    this.isNsfw = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoBlock &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          thumbnailUrl == other.thumbnailUrl &&
          width == other.width &&
          height == other.height &&
          isGifConversion == other.isGifConversion &&
          isNsfw == other.isNsfw;

  @override
  int get hashCode => Object.hash(url, thumbnailUrl, width, height, isGifConversion, isNsfw);
}

@immutable
class HtmlBlock extends ContentBlock {
  final String html;

  const HtmlBlock(this.html);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HtmlBlock && runtimeType == other.runtimeType && html == other.html;

  @override
  int get hashCode => html.hashCode;
}
