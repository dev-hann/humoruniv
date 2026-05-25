import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/user_info_row.dart';

void main() {
  group('UserInfoRow', () {
    testWidgets('should display author', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserInfoRow(author: '작성자', recommendCount: 42)),
        ),
      );

      expect(find.text('작성자'), findsOneWidget);
    });

    testWidgets('should display recommend count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserInfoRow(author: '작성자', recommendCount: 42)),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should display date when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserInfoRow(
              author: '작성자',
              recommendCount: 0,
              date: '2026-05-15',
            ),
          ),
        ),
      );

      expect(find.text('2026-05-15'), findsOneWidget);
    });

    testWidgets('should display view count when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserInfoRow(author: '작성자', recommendCount: 0, viewCount: 500),
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
    });
  });
}
