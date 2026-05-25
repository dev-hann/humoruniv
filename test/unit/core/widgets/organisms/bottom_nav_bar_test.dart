import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/organisms/bottom_nav_bar.dart';

void main() {
  group('BottomNavBar', () {
    testWidgets('should display all tab labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BottomNavBar(currentIndex: 0, onTap: (_) {})),
        ),
      );

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('게시판'), findsOneWidget);
      expect(find.text('검색'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('should call onTap with index when tab tapped', (tester) async {
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNavBar(currentIndex: 0, onTap: (i) => tappedIndex = i),
          ),
        ),
      );

      await tester.tap(find.text('게시판'));
      expect(tappedIndex, 1);
    });

    testWidgets('should display NavigationBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BottomNavBar(currentIndex: 0, onTap: (_) {})),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('should call onTap with 0 when 홈 tapped', (tester) async {
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNavBar(currentIndex: 1, onTap: (i) => tappedIndex = i),
          ),
        ),
      );

      await tester.tap(find.text('홈'));
      expect(tappedIndex, 0);
    });

    testWidgets('should call onTap with 2 when 검색 tapped', (tester) async {
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNavBar(currentIndex: 0, onTap: (i) => tappedIndex = i),
          ),
        ),
      );

      await tester.tap(find.text('검색'));
      expect(tappedIndex, 2);
    });

    testWidgets('should call onTap with 3 when 설정 tapped', (tester) async {
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomNavBar(currentIndex: 0, onTap: (i) => tappedIndex = i),
          ),
        ),
      );

      await tester.tap(find.text('설정'));
      expect(tappedIndex, 3);
    });
  });
}
