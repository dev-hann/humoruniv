import 'package:go_router/go_router.dart';
import 'package:humoruniv/presentation/screens/main_tabs_screen.dart';
import 'package:humoruniv/presentation/screens/post_detail_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainTabsScreen()),
    GoRoute(
      path: '/post',
      builder: (context, state) {
        final url = state.uri.queryParameters['url'] ?? '';
        return PostDetailScreen(postUrl: url);
      },
    ),
  ],
);
