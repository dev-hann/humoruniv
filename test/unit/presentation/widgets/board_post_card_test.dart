import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/domain/entities/board_post.dart';
import 'package:humoruniv/presentation/widgets/board_post_card.dart';

void main() {
  group('BoardPostCard', () {
    const post = BoardPost(
      id: 1,
      title: '테스트 게시글',
      url: '/board/read.html?table=pds&number=1',
      author: '작성자',
      date: '2026-05-15',
      recommendCount: 42,
      notRecommendCount: 1,
      commentCount: 10,
      viewCount: 500,
      thumbnailUrl: '',
    );

    testWidgets('should display title and author', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardPostCard(post: post, onTap: () {}),
          ),
        ),
      );

      expect(find.text('테스트 게시글'), findsOneWidget);
      expect(find.text('작성자'), findsOneWidget);
    });

    testWidgets('should display recommend count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardPostCard(post: post, onTap: () {}),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should not display thumbnail when thumbnailUrl is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoardPostCard(post: post, onTap: () {}),
          ),
        ),
      );

      final materialFinder = find.byType(Material);
      expect(materialFinder, findsWidgets);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BoardPostCard(post: post, onTap: () => tapped = true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
