import 'package:meta/meta.dart';

@immutable
class Post {
  final int id;
  final String title;
  final int recommendCount;
  final String url;

  const Post({
    required this.id,
    required this.title,
    required this.recommendCount,
    required this.url,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          recommendCount == other.recommendCount &&
          url == other.url;

  @override
  int get hashCode => Object.hash(id, title, recommendCount, url);
}
