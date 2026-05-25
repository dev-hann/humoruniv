import 'package:flutter_test/flutter_test.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

void main() {
  group('PostDetail', () {
    test('should create with required fields', () {
      final detail = PostDetail(
        id: 123,
        title: '테스트 제목',
        author: '작성자',
        date: DateTime(2026, 5, 15, 11, 0),
        contentHtml: '<p>내용</p>',
        contentBlocks: const [TextBlock('내용')],
        imageUrls: ['https://example.com/img.jpg'],
        recommendCount: 86,
        notRecommendCount: 1,
        viewCount: 36491,
        commentCount: 39,
        comments: [],
      );

      expect(detail.id, 123);
      expect(detail.title, '테스트 제목');
      expect(detail.author, '작성자');
      expect(detail.contentBlocks, hasLength(1));
      expect(detail.imageUrls, hasLength(1));
      expect(detail.recommendCount, 86);
      expect(detail.notRecommendCount, 1);
      expect(detail.viewCount, 36491);
      expect(detail.commentCount, 39);
    });

    test('should support value equality when all fields match', () {
      final a = PostDetail(
        id: 1,
        title: '제목',
        author: '작성자',
        date: DateTime(2026, 1, 1),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );
      final b = PostDetail(
        id: 1,
        title: '제목',
        author: '작성자',
        date: DateTime(2026, 1, 1),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal when id differs', () {
      final a = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );
      final b = PostDetail(
        id: 2,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when title differs', () {
      final a = PostDetail(
        id: 1,
        title: 'a',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );
      final b = PostDetail(
        id: 1,
        title: 'b',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when author differs', () {
      final a = PostDetail(
        id: 1,
        title: 't',
        author: 'x',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );
      final b = PostDetail(
        id: 1,
        title: 't',
        author: 'y',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when recommendCount differs', () {
      final a = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 10,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );
      final b = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 20,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should have isNsfw default to false', () {
      final detail = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
      );

      expect(detail.isNsfw, isFalse);
    });

    test('should create with isNsfw true', () {
      final detail = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
        isNsfw: true,
      );

      expect(detail.isNsfw, isTrue);
    });

    test('should not be equal when isNsfw differs', () {
      final a = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
        isNsfw: false,
      );
      final b = PostDetail(
        id: 1,
        title: 't',
        author: 'a',
        date: DateTime(2026),
        contentHtml: '',
        contentBlocks: const [],
        imageUrls: const [],
        recommendCount: 0,
        notRecommendCount: 0,
        viewCount: 0,
        commentCount: 0,
        comments: [],
        isNsfw: true,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('Comment', () {
    test('should create with required fields including replies', () {
      final reply = Comment(
        id: 2,
        author: '대댓글러',
        content: '대댓글 내용',
        date: DateTime(2026, 5, 15, 12, 0),
        recommendCount: 5,
        isBest: false,
        replies: [],
      );
      final comment = Comment(
        id: 1,
        author: '댓글러',
        content: '댓글 내용',
        date: DateTime(2026, 5, 15, 11, 30),
        recommendCount: 242,
        isBest: true,
        replies: [reply],
      );

      expect(comment.replies, hasLength(1));
      expect(comment.replies.first.author, '대댓글러');
      expect(comment.isBest, isTrue);
    });

    test('should support value equality', () {
      final a = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026, 1, 1),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );
      final b = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026, 1, 1),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should not be equal when id differs', () {
      final a = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );
      final b = Comment(
        id: 2,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when isBest differs', () {
      final a = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: true,
        replies: [],
      );
      final b = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when replies differ', () {
      final reply = Comment(
        id: 99,
        author: 'r',
        content: 'r',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );
      final a = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [reply],
      );
      final b = Comment(
        id: 1,
        author: 'a',
        content: 'c',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('should not be equal when content differs', () {
      final a = Comment(
        id: 1,
        author: 'a',
        content: 'x',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );
      final b = Comment(
        id: 1,
        author: 'a',
        content: 'y',
        date: DateTime(2026),
        recommendCount: 0,
        isBest: false,
        replies: [],
      );

      expect(a, isNot(equals(b)));
    });
  });
}
