import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/atoms/avatar.dart';

void main() {
  group('Avatar', () {
    testWidgets('should show person icon when imageUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Avatar())),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show CircleAvatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Avatar())),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
