import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/feed_media_sizing.dart';

void main() {
  group('FeedMediaSizing.resolve', () {
    test('short image renders at natural height without scroll', () {
      final result = FeedMediaSizing.resolve(
        aspect: 1,
        screenW: 400,
        screenH: 800,
      );
      expect(result.height, 400);
      expect(result.needsScroll, isFalse);
    });

    test('long image caps height and needs scroll', () {
      final result = FeedMediaSizing.resolve(
        aspect: 0.3,
        screenW: 400,
        screenH: 800,
      );
      expect(result.height, 640);
      expect(result.needsScroll, isTrue);
    });

    test('portrait image above old 600 cap stays natural under new cap', () {
      final result = FeedMediaSizing.resolve(
        aspect: 0.65,
        screenW: 400,
        screenH: 800,
      );
      expect(result.height, closeTo(400 / 0.65, 0.001));
      expect(result.needsScroll, isFalse);
    });

    test('very wide image is floored to 120 without scroll', () {
      final result = FeedMediaSizing.resolve(
        aspect: 10,
        screenW: 400,
        screenH: 800,
      );
      expect(result.height, 120);
      expect(result.needsScroll, isFalse);
    });
  });
}
