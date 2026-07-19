import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/atoms/retry_controller.dart';
import 'package:humoruniv/core/widgets/atoms/retryable_network_image.dart';

void main() {
  group('RetryableNetworkImage', () {
    group('construction', () {
      testWidgets('renders CachedNetworkImage for the given URL', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/test.jpg',
              ),
            ),
          ),
        );

        expect(find.byType(RetryableNetworkImage), findsOneWidget);
        expect(
          find.byType(Image),
          findsWidgets,
          reason: 'CachedNetworkImage은 로딩 중에도 Image 위젯을 렌더함',
        );
      });

      testWidgets('applies ClipRRect when borderRadius is provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/test.jpg',
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        );

        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('does not apply ClipRRect when borderRadius is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/test.jpg',
              ),
            ),
          ),
        );

        expect(find.byType(ClipRRect), findsNothing);
      });
    });

    group('error view (manual retry affordance)', () {
      testWidgets(
        'shows retry hint with refresh icon when controller is exhausted',
        (tester) async {
          final controller = RetryController(maxAttempts: 1);
          addTearDown(controller.dispose);
          // 강제로 exhausted 상태로 진입
          controller.recordFailure();
          await tester.pump();

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RetryableNetworkImage(
                  imageUrl: 'https://example.com/x.jpg',
                  controller: controller,
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.byIcon(Icons.refresh), findsOneWidget);
          expect(find.text('탭하여 재시도'), findsOneWidget);
        },
      );

      testWidgets('uses custom errorIcon when provided', (tester) async {
        final controller = RetryController(maxAttempts: 1);
        addTearDown(controller.dispose);
        controller.recordFailure();
        await tester.pump();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/x.jpg',
                controller: controller,
                errorIcon: Icons.sentiment_dissatisfied,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsNothing);
      });

      testWidgets('uses custom foregroundColor for icon when provided', (
        tester,
      ) async {
        final controller = RetryController(maxAttempts: 1);
        addTearDown(controller.dispose);
        controller.recordFailure();
        await tester.pump();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/x.jpg',
                controller: controller,
                foregroundColor: Colors.pink,
              ),
            ),
          ),
        );
        await tester.pump();

        final icon = tester.widget<Icon>(find.byIcon(Icons.refresh));
        expect(icon.color, Colors.pink);
      });

      testWidgets('tapping retry hint calls controller.manualRetry', (
        tester,
      ) async {
        final controller = RetryController(maxAttempts: 1);
        addTearDown(controller.dispose);
        controller.recordFailure();
        await tester.pump();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/x.jpg',
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(controller.attempt, 0);
        expect(controller.isExhausted, isTrue);

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        expect(controller.attempt, 0);
        expect(controller.isExhausted, isFalse);
      });
    });

    group('URL change', () {
      testWidgets('resets controller when imageUrl changes', (tester) async {
        final controller = RetryController(maxAttempts: 1);
        addTearDown(controller.dispose);
        controller.recordFailure();
        await tester.pump();
        expect(controller.isExhausted, isTrue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/old.jpg',
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryableNetworkImage(
                imageUrl: 'https://example.com/new.jpg',
                controller: controller,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(controller.attempt, 0, reason: 'URL 변경 시 컨트롤러가 리셋되어야 함');
      });
    });
  });
}
