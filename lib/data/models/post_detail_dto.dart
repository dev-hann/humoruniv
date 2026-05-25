import 'package:humoruniv/data/models/comment_dto.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

class PostDetailDto {
  final int id;
  final String title;
  final String author;
  final DateTime date;
  final String contentHtml;
  final List<String> imageUrls;
  final int recommendCount;
  final int notRecommendCount;
  final int viewCount;
  final int commentCount;
  final List<CommentDto> comments;

  const PostDetailDto({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.contentHtml,
    required this.imageUrls,
    required this.recommendCount,
    required this.notRecommendCount,
    required this.viewCount,
    required this.commentCount,
    required this.comments,
  });

  PostDetail toEntity() => PostDetail(
        id: id,
        title: title,
        author: author,
        date: date,
        contentHtml: contentHtml,
        contentBlocks: [],
        imageUrls: imageUrls,
        recommendCount: recommendCount,
        notRecommendCount: notRecommendCount,
        viewCount: viewCount,
        commentCount: commentCount,
        comments: comments.map((c) => c.toEntity()).toList(),
      );
}
