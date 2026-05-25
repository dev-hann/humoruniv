import 'package:humoruniv/data/models/board_post_dto.dart';
import 'package:humoruniv/data/models/post_dto.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

class BoardListDsResult {
  final List<BoardPostDto> posts;
  final int currentPage;
  final int totalPage;

  const BoardListDsResult({
    required this.posts,
    required this.currentPage,
    required this.totalPage,
  });
}

abstract class HumorunivRemoteDs {
  Future<List<PostDto>> fetchMainPage();
  Future<PostDetail> fetchPostDetail(String url);
  Future<BoardListDsResult> fetchBoardList(String table, int page, String sort);
}
