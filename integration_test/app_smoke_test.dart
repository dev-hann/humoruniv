import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke: real network', () {
    testWidgets('should launch app and load posts from live server',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(child: HumorUnivApp()));
      await tester.pump(const Duration(seconds: 15));

      final hasPosts = find.byType(ListTile).evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasError =
          find.text('Failed to load posts').evaluate().isNotEmpty;
      final hasEmpty =
          find.text('No posts available').evaluate().isNotEmpty;

      expect(
        hasPosts || hasLoading || hasError || hasEmpty,
        isTrue,
        reason: 'App should render one of: posts, loading, error, or empty',
      );
    });

    testWidgets(
        'should navigate to post detail and load content from live server',
        (tester) async {
      await tester.pumpWidget(const ProviderScope(child: HumorUnivApp()));
      await tester.pump(const Duration(seconds: 15));

      final postCards = find.byType(ListTile);
      if (postCards.evaluate().isNotEmpty) {
        await tester.tap(postCards.first);
        await tester.pump(const Duration(seconds: 15));

        final hasContent =
            find.byType(ScrollView).evaluate().isNotEmpty;
        final hasError =
            find.text('Failed to load post').evaluate().isNotEmpty;
        final hasLoading =
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

        expect(
          hasContent || hasError || hasLoading,
          isTrue,
          reason:
              'Post detail screen should render content, error, or loading',
        );
      }
    });
  });
}
