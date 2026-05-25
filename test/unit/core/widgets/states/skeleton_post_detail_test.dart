import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_detail.dart';

void main() {
  group('SkeletonPostDetail', () {
    testWidgets('should render skeleton boxes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonPostDetail())),
      );

      expect(find.byType(SkeletonPostDetail), findsOneWidget);
    });

    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonPostDetail())),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
