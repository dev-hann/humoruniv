import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';

void main() {
  group('SkeletonPostList', () {
    testWidgets('should render default 5 items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 800, child: SkeletonPostList()),
          ),
        ),
      );

      expect(find.byType(SkeletonPostList), findsOneWidget);
    });

    testWidgets('should render specified item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 800, child: SkeletonPostList(itemCount: 3)),
          ),
        ),
      );

      expect(find.byType(SkeletonPostList), findsOneWidget);
    });
  });
}
