import 'package:humoruniv/core/themes/app_sizes.dart';

class FeedMediaSizing {
  const FeedMediaSizing._();

  static ({double height, bool needsScroll}) resolve({
    required double aspect,
    required double screenW,
    required double screenH,
  }) {
    final cap = screenH * AppSizes.feedLongImageCapRatio;
    final natural = screenW / aspect;
    if (natural > cap) {
      return (height: cap, needsScroll: true);
    }
    return (height: natural.clamp(120.0, cap), needsScroll: false);
  }
}
