import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/main.dart';

void main() {
  testWidgets('should render HumorUniv title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HumorUnivApp()),
    );

    expect(find.text('웃긴자료 베스트'), findsOneWidget);
  });
}
