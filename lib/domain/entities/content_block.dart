import 'package:meta/meta.dart';

sealed class ContentBlock {
  const ContentBlock();
}

@immutable
class TextBlock extends ContentBlock {
  const TextBlock(this.text);
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextBlock &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

@immutable
class ImageBlock extends ContentBlock {
  const ImageBlock({required this.url, this.thumbnailUrl, this.isNsfw = false});
  final String url;
  final String? thumbnailUrl;
  final bool isNsfw;

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
  const VideoBlock({
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.isGifConversion = false,
    this.isNsfw = false,
  });
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final bool isGifConversion;
  final bool isNsfw;

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
  int get hashCode =>
      Object.hash(url, thumbnailUrl, width, height, isGifConversion, isNsfw);
}

@immutable
class HtmlBlock extends ContentBlock {
  const HtmlBlock(this.html);
  final String html;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HtmlBlock &&
          runtimeType == other.runtimeType &&
          html == other.html;

  @override
  int get hashCode => html.hashCode;
}
