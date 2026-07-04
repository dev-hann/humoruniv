import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';

void main() {
  group('ImageViewerScreen', () {
    testWidgets('renders close button for a single image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ImageViewerScreen(imageUrls: ['https://example.com/a.jpg']),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders page indicator for multiple images', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ImageViewerScreen(
            imageUrls: [
              'https://example.com/a.jpg',
              'https://example.com/b.jpg',
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1 / 2'), findsOneWidget);
    });
  });
}
