import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/core/widgets/molecules/comment_tile.dart';

void main() {
  group('CommentTile', () {
    testWidgets('should display author and content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentTile(
              author: '테스터',
              content: '댓글 내용',
              recommendCount: 5,
            ),
          ),
        ),
      );

      expect(find.text('테스터'), findsOneWidget);
      expect(find.text('댓글 내용'), findsOneWidget);
    });

    testWidgets('should display BEST badge when isBest is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentTile(
              author: '테스터',
              content: '베스트 댓글',
              recommendCount: 100,
              isBest: true,
            ),
          ),
        ),
      );

      expect(find.text('BEST'), findsOneWidget);
    });

    testWidgets(
        'should not display BEST badge when isBest is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentTile(
              author: '테스터',
              content: '일반 댓글',
              recommendCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('BEST'), findsNothing);
    });

    testWidgets('should display replies', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentTile(
              author: '테스터',
              content: '댓글',
              recommendCount: 5,
              replies: [
                CommentReply(
                  author: '대댓글러',
                  content: '대댓글 내용',
                  recommendCount: 3,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('대댓글러'), findsOneWidget);
      expect(find.text('대댓글 내용'), findsOneWidget);
    });

    testWidgets('should not display replies when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentTile(
              author: '테스터',
              content: '댓글',
              recommendCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('테스터'), findsOneWidget);
    });
  });
}
