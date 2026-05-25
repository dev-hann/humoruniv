import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/presentation/screens/image_viewer_screen.dart';

void main() {
  testWidgets('should display image from url', (tester) async {
    final urls = ['https://example.com/img1.jpg'];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageViewerScreen(imageUrls: urls, initialIndex: 0),
      ),
    );

    expect(find.byType(ImageViewerScreen), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('should display position indicator', (tester) async {
    final urls = [
      'https://example.com/img1.jpg',
      'https://example.com/img2.jpg',
      'https://example.com/img3.jpg',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageViewerScreen(imageUrls: urls, initialIndex: 1),
    ));

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('should display close button', (tester) async {
    final urls = ['https://example.com/img1.jpg'];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageViewerScreen(imageUrls: urls, initialIndex: 0),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('should pop when close button tapped', (tester) async {
    final urls = ['https://example.com/img1.jpg'];
    bool popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(imageUrls: urls, initialIndex: 0),
                  ),
                ).then((_) => popped = true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ImageViewerScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });

  testWidgets('should show single image without position indicator', (tester) async {
    final urls = ['https://example.com/img1.jpg'];

    await tester.pumpWidget(
      MaterialApp(
        home: ImageViewerScreen(imageUrls: urls, initialIndex: 0),
      ),
    );

    expect(find.byType(PageView), findsNothing);
  });
}
