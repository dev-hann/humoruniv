import 'package:humoruniv/domain/entities/comment.dart';

class CommentDto {
  const CommentDto({
    required this.id,
    required this.author,
    required this.content,
    required this.date,
    required this.recommendCount,
    required this.isBest,
    required this.replies,
  });
  final int id;
  final String author;
  final String content;
  final DateTime date;
  final int recommendCount;
  final bool isBest;
  final List<CommentDto> replies;

  Comment toEntity() => Comment(
    id: id,
    author: author,
    content: content,
    date: date,
    recommendCount: recommendCount,
    isBest: isBest,
    replies: replies.map((r) => r.toEntity()).toList(),
  );
}
