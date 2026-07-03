import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/themes/app_sizes.dart';
import 'package:humoruniv/core/widgets/molecules/update_banner.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';

void main() {
  group('UpdateBanner', () {
    testWidgets('should show check button when idle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdateBanner(status: UpdateCheckStatus.idle)),
        ),
      );

      expect(find.text('업데이트 확인'), findsOneWidget);
    });

    testWidgets('should show loading indicator when checking', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpdateBanner(status: UpdateCheckStatus.checking),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show up to date text when up to date', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpdateBanner(status: UpdateCheckStatus.upToDate),
          ),
        ),
      );

      expect(find.text('최신 버전입니다'), findsOneWidget);
    });

    testWidgets('should show update button when available', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpdateBanner(
              status: UpdateCheckStatus.available,
              newVersion: '1.2.0',
            ),
          ),
        ),
      );

      expect(find.text('v1.2.0 사용 가능'), findsOneWidget);
      expect(find.text('업데이트'), findsOneWidget);
    });

    testWidgets('should show error text when error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdateBanner(status: UpdateCheckStatus.error)),
        ),
      );

      expect(find.text('확인 실패'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show error_outline icon when error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdateBanner(status: UpdateCheckStatus.error)),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show check_circle icon when up to date', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UpdateBanner(status: UpdateCheckStatus.upToDate),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call onCheck when error state tapped', (tester) async {
      var checked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpdateBanner(
              status: UpdateCheckStatus.error,
              onCheck: () => checked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(checked, true);
    });

    testWidgets('error retry touch target should be at least 44pt tall', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdateBanner(status: UpdateCheckStatus.error)),
        ),
      );

      final size = tester.getSize(find.byType(InkWell));
      expect(size.height, greaterThanOrEqualTo(AppSizes.minTouchTarget));
    });

    testWidgets('should call onCheck when check button tapped', (tester) async {
      var checked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpdateBanner(
              status: UpdateCheckStatus.idle,
              onCheck: () => checked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('업데이트 확인'));
      expect(checked, true);
    });

    testWidgets('should call onUpdate when update button tapped', (
      tester,
    ) async {
      var updated = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpdateBanner(
              status: UpdateCheckStatus.available,
              newVersion: '1.2.0',
              onUpdate: () => updated = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('업데이트'));
      expect(updated, true);
    });
  });
}
