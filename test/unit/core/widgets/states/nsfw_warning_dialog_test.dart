import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/states/nsfw_warning_dialog.dart';

void main() {
  group('NsfwWarningDialog', () {
    testWidgets('should display warning title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => NsfwWarningDialog(
                      onAcknowledge: () {},
                    ),
                  );
                },
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('콘텐츠 경고'), findsOneWidget);
    });

    testWidgets('should display acknowledge button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => NsfwWarningDialog(
                      onAcknowledge: () {},
                    ),
                  );
                },
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('should call onAcknowledge and close on confirm',
        (tester) async {
      var acknowledged = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => NsfwWarningDialog(
                      onAcknowledge: () => acknowledged = true,
                    ),
                  );
                },
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      expect(acknowledged, isTrue);
      expect(find.text('콘텐츠 경고'), findsNothing);
    });
  });
}
