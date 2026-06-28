import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/feed_image_carousel.dart';

void main() {
  group('FeedImageCarousel', () {
    testWidgets('single image shows no indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(imageUrls: ['https://example.com/a.jpg']),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('1/1'), findsNothing);
    });

    testWidgets('multiple images show "1/N" indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedImageCarousel(imageUrls: ['a', 'b', 'c'])),
        ),
      );
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('swipe advances the indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FeedImageCarousel(imageUrls: ['a', 'b'])),
        ),
      );
      expect(find.text('1/2'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('tap calls onImageTap with index', (tester) async {
      var tapped = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedImageCarousel(
              imageUrls: const ['a', 'b'],
              onImageTap: (i) => tapped = i,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Image).first);
      expect(tapped, 0);
    });
  });
}
