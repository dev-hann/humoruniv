import 'package:humoruniv/domain/entities/post.dart';

class PostDto {
  final int id;
  final String title;
  final int recommendCount;
  final String url;

  const PostDto({
    required this.id,
    required this.title,
    required this.recommendCount,
    required this.url,
  });

  Post toEntity() => Post(
        id: id,
        title: title,
        recommendCount: recommendCount,
        url: url,
      );
}
