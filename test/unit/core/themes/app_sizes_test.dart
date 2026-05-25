import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';

void main() {
  group('AppSizes', () {
    test('minTouchTarget should be 44', () {
      expect(AppSizes.minTouchTarget, 44);
    });

    test('thumbnail small should be 48', () {
      expect(AppSizes.thumbnailSmall, 48);
    });

    test('thumbnail medium should be 72', () {
      expect(AppSizes.thumbnailMedium, 72);
    });

    test('thumbnail large should be 120', () {
      expect(AppSizes.thumbnailLarge, 120);
    });

    test('screenHPadding should be 16', () {
      expect(AppSizes.screenHPadding, 16);
    });

    test('thumbnail sizes should be ordered small < medium < large', () {
      expect(AppSizes.thumbnailSmall < AppSizes.thumbnailMedium, isTrue);
      expect(AppSizes.thumbnailMedium < AppSizes.thumbnailLarge, isTrue);
    });

    test('minTouchTarget should be at least 44', () {
      expect(AppSizes.minTouchTarget, greaterThanOrEqualTo(44));
    });
  });
}
