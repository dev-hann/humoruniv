import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/widgets/content_block_view.dart';

void main() {
  group('ContentBlockView (compact — comment media)', () {
    testWidgets('should render nothing for TextBlock', (tester) async {
      const block = TextBlock('Hello World');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(block: block, allImageUrls: []),
          ),
        ),
      );

      expect(find.text('Hello World'), findsNothing);
    });

    testWidgets('should render nothing for empty TextBlock', (tester) async {
      const block = TextBlock('');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(block: block, allImageUrls: []),
          ),
        ),
      );

      expect(find.text(''), findsNothing);
    });

    testWidgets('should render compact image thumbnail for ImageBlock', (
      tester,
    ) async {
      const block = ImageBlock(url: 'https://example.com/test.jpg');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(
              block: block,
              allImageUrls: ['https://example.com/test.jpg'],
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should render compact video thumbnail for VideoBlock', (
      tester,
    ) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(block: block, allImageUrls: []),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets(
      'should show NSFW placeholder for NSFW ImageBlock when hideNsfw is true',
      (tester) async {
        const block = ImageBlock(
          url: 'https://example.com/nsfw.jpg',
          isNsfw: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(
                block: block,
                allImageUrls: ['https://example.com/nsfw.jpg'],
              ),
            ),
          ),
        );

        expect(find.text('민감한 콘텐츠'), findsOneWidget);
        expect(find.text('탭하여 보기'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'should not show placeholder for NSFW ImageBlock when hideNsfw is false',
      (tester) async {
        const block = ImageBlock(
          url: 'https://example.com/nsfw.jpg',
          isNsfw: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(
                block: block,
                allImageUrls: ['https://example.com/nsfw.jpg'],
                hideNsfw: false,
              ),
            ),
          ),
        );

        expect(find.text('민감한 콘텐츠'), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'should not show placeholder for safe ImageBlock when hideNsfw is true',
      (tester) async {
        const block = ImageBlock(url: 'https://example.com/safe.jpg');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(
                block: block,
                allImageUrls: ['https://example.com/safe.jpg'],
              ),
            ),
          ),
        );

        expect(find.text('민감한 콘텐츠'), findsNothing);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('should reveal NSFW image after tapping placeholder', (
      tester,
    ) async {
      const block = ImageBlock(
        url: 'https://example.com/nsfw.jpg',
        isNsfw: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(
              block: block,
              allImageUrls: ['https://example.com/nsfw.jpg'],
            ),
          ),
        ),
      );

      expect(find.text('민감한 콘텐츠'), findsOneWidget);

      await tester.tap(find.text('민감한 콘텐츠'));
      await tester.pumpAndSettle();

      expect(find.text('민감한 콘텐츠'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets(
      'should show NSFW placeholder for NSFW VideoBlock when hideNsfw is true',
      (tester) async {
        const block = VideoBlock(
          url: 'https://example.com/nsfw.mp4',
          isNsfw: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(block: block, allImageUrls: []),
            ),
          ),
        );

        expect(find.text('민감한 콘텐츠'), findsOneWidget);
      },
    );
  });
}
