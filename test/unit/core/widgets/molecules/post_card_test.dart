import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/post_card.dart';

void main() {
  group('PostCard', () {
    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '테스트 제목',
              author: '작성자',
              recommendCount: 42,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('테스트 제목'), findsOneWidget);
    });

    testWidgets('should display author', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '제목',
              author: '작성자',
              recommendCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('작성자'), findsOneWidget);
    });

    testWidgets('should display recommend count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '제목',
              author: '작성자',
              recommendCount: 42,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '제목',
              author: '작성자',
              recommendCount: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('should display comment count when non-zero',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '제목',
              author: '작성자',
              recommendCount: 0,
              commentCount: 15,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('should not display comment badge when count is 0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              title: '제목',
              author: '작성자',
              recommendCount: 0,
              commentCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.comment), findsNothing);
    });
  });
}
