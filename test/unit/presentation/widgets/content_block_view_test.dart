import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/widgets/content_block_view.dart';

void main() {
  group('ContentBlockView', () {
    testWidgets('should display text for TextBlock', (tester) async {
      const block = TextBlock('Hello World');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(block: block, allImageUrls: []),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
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

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should display image for ImageBlock', (tester) async {
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

    testWidgets('should render SizedBox for VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContentBlockView(block: block, allImageUrls: []),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    group('VideoBlock controls', () {
      testWidgets('should show play icon for non-GIF VideoBlock', (
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
        await tester.pump();

        expect(find.byIcon(Icons.play_arrow), findsWidgets);
      });

      testWidgets('should show muted icon by default for VideoBlock', (
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
        await tester.pump();

        expect(find.byIcon(Icons.volume_off), findsOneWidget);
      });

      testWidgets('should show fullscreen icon for VideoBlock', (tester) async {
        const block = VideoBlock(url: 'https://example.com/video.mp4');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(block: block, allImageUrls: []),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      });

      testWidgets('should show time display for VideoBlock', (tester) async {
        const block = VideoBlock(url: 'https://example.com/video.mp4');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ContentBlockView(block: block, allImageUrls: []),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('0:00 / 0:00'), findsOneWidget);
      });

      testWidgets(
        'should not show control bar for isGifConversion VideoBlock',
        (tester) async {
          const block = VideoBlock(
            url: 'https://example.com/clip.mp4',
            isGifConversion: true,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ContentBlockView(block: block, allImageUrls: []),
              ),
            ),
          );
          await tester.pump();

          expect(find.byIcon(Icons.volume_off), findsNothing);
          expect(find.byIcon(Icons.fullscreen), findsNothing);
          expect(find.text('0:00 / 0:00'), findsNothing);
        },
      );

      testWidgets(
        'should show center play button for isGifConversion VideoBlock',
        (tester) async {
          const block = VideoBlock(
            url: 'https://example.com/clip.mp4',
            isGifConversion: true,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ContentBlockView(block: block, allImageUrls: []),
              ),
            ),
          );
          await tester.pump();

          expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        },
      );
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
  });
}
