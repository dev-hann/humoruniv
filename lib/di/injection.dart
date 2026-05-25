import 'package:get_it/get_it.dart';
import 'package:humoruniv/core/network/html_client_impl.dart';
import 'package:humoruniv/data/datasources/humoruniv_remote_ds.dart';
import 'package:humoruniv/data/datasources/humoruniv_remote_ds_impl.dart';
import 'package:humoruniv/data/repositories/post_repository_impl.dart';
import 'package:humoruniv/domain/repositories/post_repository.dart';
import 'package:humoruniv/domain/usecases/get_best_posts.dart';
import 'package:humoruniv/domain/usecases/get_board_posts.dart';
import 'package:humoruniv/domain/usecases/get_post_detail.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<HtmlClientImpl>(HtmlClientImpl.new);

  sl.registerLazySingleton<HumorunivRemoteDs>(
    () => HumorunivRemoteDsImpl(htmlClient: sl<HtmlClientImpl>()),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDs: sl<HumorunivRemoteDs>()),
  );

  sl.registerLazySingleton(
    () => GetBestPosts(repository: sl<PostRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPostDetail(repository: sl<PostRepository>()),
  );
  sl.registerLazySingleton(
    () => GetBoardPosts(repository: sl<PostRepository>()),
  );
}
