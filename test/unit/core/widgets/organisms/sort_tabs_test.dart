import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/domain/entities/sort_option.dart';
import 'package:humoruniv/presentation/screens/board_screen.dart';

void main() {
  group('SortTabs', () {
    testWidgets('should display all 6 sort labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.all, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('전체'), findsOneWidget);
      expect(find.text('일간'), findsOneWidget);
      expect(find.text('주간'), findsOneWidget);
      expect(find.text('월간'), findsOneWidget);
      expect(find.text('연간'), findsOneWidget);
      expect(find.text('추천500'), findsOneWidget);
    });

    testWidgets('should render 6 ChoiceChips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.all, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byType(ChoiceChip), findsNWidgets(6));
    });

    testWidgets('should select chip matching currentSort', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.week, onChanged: (_) {}),
          ),
        ),
      );

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      final weekChip = chips.firstWhere((c) => (c.label as Text).data == '주간');
      final allChip = chips.firstWhere((c) => (c.label as Text).data == '전체');

      expect(weekChip.selected, true);
      expect(allChip.selected, false);
    });

    testWidgets('should call onChanged with correct SortOption on tap', (
      tester,
    ) async {
      SortOption? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(
              currentSort: SortOption.all,
              onChanged: (s) => selected = s,
            ),
          ),
        ),
      );

      await tester.tap(find.text('일간'));
      expect(selected, SortOption.day);
    });

    testWidgets('should call onChanged for each chip', (tester) async {
      final selected = <SortOption>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(
              currentSort: SortOption.all,
              onChanged: selected.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('전체'));
      await tester.tap(find.text('일간'));
      await tester.tap(find.text('주간'));
      await tester.tap(find.text('월간'));
      await tester.tap(find.text('연간'));
      await tester.tap(find.text('추천500'));

      expect(selected, [
        SortOption.all,
        SortOption.day,
        SortOption.week,
        SortOption.month,
        SortOption.year,
        SortOption.recommend500,
      ]);
    });

    testWidgets('should be wrapped in horizontal SingleChildScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.all, onChanged: (_) {}),
          ),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('selection changes when currentSort changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.all, onChanged: (_) {}),
          ),
        ),
      );

      var chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      var allChip = chips.firstWhere((c) => (c.label as Text).data == '전체');
      expect(allChip.selected, true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortTabs(currentSort: SortOption.month, onChanged: (_) {}),
          ),
        ),
      );

      chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      allChip = chips.firstWhere((c) => (c.label as Text).data == '전체');
      final monthChip = chips.firstWhere((c) => (c.label as Text).data == '월간');

      expect(allChip.selected, false);
      expect(monthChip.selected, true);
    });
  });
}
