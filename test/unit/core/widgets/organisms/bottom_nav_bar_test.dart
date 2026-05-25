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
      expect(find.text('최신'), findsOneWidget);
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

      await tester.tap(find.text('최신'));
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
  });
}
