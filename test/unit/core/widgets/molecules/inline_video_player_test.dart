import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/inline_video_player.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

void main() {
  group('InlineVideoPlayer', () {
    testWidgets('should show play icon for non-GIF VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InlineVideoPlayer(block: block)),
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
          home: Scaffold(body: InlineVideoPlayer(block: block)),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('should show fullscreen icon for VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InlineVideoPlayer(block: block)),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });

    testWidgets('should show time display for VideoBlock', (tester) async {
      const block = VideoBlock(url: 'https://example.com/video.mp4');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InlineVideoPlayer(block: block)),
        ),
      );
      await tester.pump();

      expect(find.text('0:00 / 0:00'), findsOneWidget);
    });

    testWidgets('should not show control bar for isGifConversion VideoBlock', (
      tester,
    ) async {
      const block = VideoBlock(
        url: 'https://example.com/clip.mp4',
        isGifConversion: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InlineVideoPlayer(block: block)),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsNothing);
      expect(find.byIcon(Icons.fullscreen), findsNothing);
      expect(find.text('0:00 / 0:00'), findsNothing);
    });

    testWidgets(
      'should show center play button for isGifConversion VideoBlock',
      (tester) async {
        const block = VideoBlock(
          url: 'https://example.com/clip.mp4',
          isGifConversion: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: InlineVideoPlayer(block: block)),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      },
    );
  });
}
