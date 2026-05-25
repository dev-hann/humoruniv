import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/hero_card.dart';

void main() {
  group('HeroCard', () {
    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroCard(
              title: '오늘의 베스트',
              author: '작성자',
              recommendCount: 999,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('오늘의 베스트'), findsOneWidget);
    });

    testWidgets('should display author', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroCard(
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

    testWidgets('should display today label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroCard(
              title: '제목',
              author: '작성자',
              recommendCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('오늘의 1위'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroCard(
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
  });
}
