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

    testWidgets('renders a PageView for paging between images', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ImageViewerScreen(imageUrls: ['https://example.com/a.jpg']),
        ),
      );
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('renders InteractiveViewer for a normal image', (tester) async {
      // viewport default 800x600 → viewportAspect 1.33; aspect 2.0 (wide) is NOT long.
      await tester.pumpWidget(
        MaterialApp(
          home: ImageViewerScreen(
            imageUrls: ['https://example.com/a.jpg'],
            knownAspects: {'https://example.com/a.jpg': 2.0},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('renders vertical SingleChildScrollView for a long image '
        'instead of InteractiveViewer', (tester) async {
      // aspect 0.5 (tall) < viewportAspect 1.33 → long image.
      await tester.pumpWidget(
        MaterialApp(
          home: ImageViewerScreen(
            imageUrls: ['https://example.com/a.jpg'],
            knownAspects: {'https://example.com/a.jpg': 0.5},
          ),
        ),
      );
      await tester.pump();

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scrollView.scrollDirection,
        Axis.vertical,
        reason: 'long image must scroll vertically',
      );
      expect(
        find.byType(InteractiveViewer),
        findsNothing,
        reason: 'long image must not use InteractiveViewer',
      );
    });

    testWidgets('close button pops the screen', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('root')),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) =>
              const ImageViewerScreen(imageUrls: ['https://example.com/a.jpg']),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('root'), findsOneWidget);
    });

    testWidgets('swiping down on a normal image dismisses the viewer', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('root')),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) =>
              const ImageViewerScreen(imageUrls: ['https://example.com/a.jpg']),
        ),
      );
      await tester.pumpAndSettle();

      // Drag down past the dismiss threshold (>25% of 600px screen height).
      await tester.fling(find.byType(PageView), const Offset(0, 250), 1000);
      await tester.pumpAndSettle();

      expect(find.text('root'), findsOneWidget);
    });
  });
}
