import 'package:meta/meta.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

@immutable
class Comment {
  final int id;
  final String author;
  final String content;
  final DateTime date;
  final int recommendCount;
  final bool isBest;
  final List<ContentBlock> mediaBlocks;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.date,
    required this.recommendCount,
    required this.isBest,
    this.mediaBlocks = const [],
    required this.replies,
  });

  List<String> get imageUrls => mediaBlocks
      .whereType<ImageBlock>()
      .map((b) => b.url)
      .toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          author == other.author &&
          content == other.content &&
          date == other.date &&
          recommendCount == other.recommendCount &&
          isBest == other.isBest &&
          _listEquals(replies, other.replies);

  static bool _listEquals(List<Comment> a, List<Comment> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(id, author, content, date, recommendCount, isBest);
}
