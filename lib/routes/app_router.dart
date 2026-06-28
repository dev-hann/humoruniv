import 'package:go_router/go_router.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
