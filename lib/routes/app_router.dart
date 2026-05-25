import 'package:go_router/go_router.dart';
import 'package:humoruniv/presentation/screens/board_screen.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/presentation/screens/post_detail_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/board/:table',
      builder: (context, state) {
        final table = state.pathParameters['table'] ?? 'pds';
        return BoardScreen(table: table);
      },
    ),
    GoRoute(
      path: '/post',
      builder: (context, state) {
        final url = state.uri.queryParameters['url'] ?? '';
        return PostDetailScreen(postUrl: url);
      },
    ),
  ],
);
