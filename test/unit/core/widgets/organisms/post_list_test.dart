import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/organisms/post_list.dart';

void main() {
  group('PostList', () {
    final items = [
      PostListItem(
        title: '첫 번째',
        author: '작성자',
        recommendCount: 100,
      ),
      PostListItem(
        title: '두 번째',
        author: '작성자2',
        recommendCount: 50,
      ),
    ];

    testWidgets('should display post titles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(
              items: items,
              onPostTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('첫 번째'), findsOneWidget);
      expect(find.text('두 번째'), findsOneWidget);
    });

    testWidgets('should show empty view when items empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(
              items: const [],
              onPostTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('게시글이 없습니다.'), findsOneWidget);
    });

    testWidgets('should show error view when hasError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(
              items: const [],
              hasError: true,
              errorMessage: '에러',
              onPostTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('에러'), findsOneWidget);
    });

    testWidgets('should display filter bar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(
              items: items,
              onPostTap: (_) {},
              filterBar: const Text('필터바'),
            ),
          ),
        ),
      );

      expect(find.text('필터바'), findsOneWidget);
    });

    testWidgets('should display pagination when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostList(
              items: items,
              onPostTap: (_) {},
              pagination: const Text('1 / 5'),
            ),
          ),
        ),
      );

      expect(find.text('1 / 5'), findsOneWidget);
    });
  });
}
