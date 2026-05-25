import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/organisms/home_feed.dart';
import 'package:humoruniv/core/widgets/states/skeleton_post_list.dart';

void main() {
  group('HomeFeed', () {
    testWidgets('should show skeleton when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeFeed(items: const [], isLoading: true, onPostTap: (_) {}),
          ),
        ),
      );

      expect(find.byType(SkeletonPostList), findsOneWidget);
    });

    testWidgets('should show error view when hasError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeFeed(
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

    testWidgets('should show empty view when items empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeFeed(items: const [], onPostTap: (_) {}),
          ),
        ),
      );

      expect(find.text('게시글이 없습니다.'), findsOneWidget);
    });

    testWidgets('should display items with hero card for first item', (
      tester,
    ) async {
      final items = [
        const HomeFeedItem(title: '첫 번째', author: '작성자', recommendCount: 100),
        const HomeFeedItem(title: '두 번째', author: '작성자', recommendCount: 50),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeFeed(items: items, onPostTap: (_) {}),
          ),
        ),
      );

      expect(find.text('첫 번째'), findsOneWidget);
      expect(find.text('두 번째'), findsOneWidget);
      expect(find.text('오늘의 1위'), findsOneWidget);
    });

    testWidgets('should call onPostTap when item tapped', (tester) async {
      var tappedIndex = -1;
      final items = [
        const HomeFeedItem(title: '첫 번째', author: '작성자', recommendCount: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeFeed(items: items, onPostTap: (i) => tappedIndex = i),
          ),
        ),
      );

      await tester.tap(find.text('첫 번째'));
      expect(tappedIndex, 0);
    });
  });
}
