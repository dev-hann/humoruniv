import 'package:dio/dio.dart';

abstract class GitHubRemoteDs {
  Future<String> fetchLatestRelease();
}
