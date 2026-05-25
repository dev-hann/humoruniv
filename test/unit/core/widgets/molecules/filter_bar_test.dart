import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/filter_bar.dart';

void main() {
  group('FilterBar', () {
    const options = [
      FilterOption(value: 'all', label: '전체'),
      FilterOption(value: 'day', label: '일간'),
      FilterOption(value: 'week', label: '주간'),
    ];

    testWidgets('should display all option labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar<String>(
              options: options,
              selectedValue: 'all',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('전체'), findsOneWidget);
      expect(find.text('일간'), findsOneWidget);
      expect(find.text('주간'), findsOneWidget);
    });

    testWidgets('should call onChanged when option tapped', (tester) async {
      var selected = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterBar<String>(
              options: options,
              selectedValue: 'all',
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('주간'));
      expect(selected, 'week');
    });
  });
}
