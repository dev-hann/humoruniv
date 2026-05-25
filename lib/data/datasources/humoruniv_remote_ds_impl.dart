import 'package:flutter/foundation.dart';
import 'package:humoruniv/core/errors/failures.dart';
import 'package:humoruniv/core/network/html_client.dart';
import 'package:humoruniv/data/datasources/humoruniv_remote_ds.dart';
import 'package:humoruniv/data/models/board_post_dto.dart';
import 'package:humoruniv/data/models/post_dto.dart';
import 'package:humoruniv/data/parsers/board_list_parser.dart';
import 'package:humoruniv/data/parsers/main_page_parser.dart';
import 'package:humoruniv/data/parsers/post_detail_parser.dart';
import 'package:humoruniv/domain/entities/post_detail.dart';

class HumorunivRemoteDsImpl implements HumorunivRemoteDs {
  final HtmlClient htmlClient;

  const HumorunivRemoteDsImpl({required this.htmlClient});

  @override
  Future<List<PostDto>> fetchMainPage() async {
    try {
      debugPrint('DS: fetching /main.html');
      final html = await htmlClient.get('/main.html');
      debugPrint('DS: got html length=${html.length}');
      final result = MainPageParser.parseBestPosts(html);
      debugPrint('DS: parsed ${result.length} posts');
      return result;
    } on ServerFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } catch (e, st) {
      debugPrint('DS ERROR fetchMainPage: $e\n$st');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PostDetail> fetchPostDetail(String url) async {
    try {
      final html = await htmlClient.get(url);
      return PostDetailParser.parse(html);
    } on ServerFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BoardListDsResult> fetchBoardList(
    String table,
    int page,
    String sort,
  ) async {
    try {
      final sortParam = sort.isNotEmpty ? '&sort=$sort' : '';
      final path = '/board/list.html?table=$table&pg=$page$sortParam';
      debugPrint('DS: fetching $path');
      final html = await htmlClient.get(path);
      final result = BoardListParser.parse(html);
      return BoardListDsResult(
        posts: result.posts,
        currentPage: result.currentPage,
        totalPage: result.totalPage,
      );
    } on ServerFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
