import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:humoruniv/core/themes/app_theme.dart';
import 'package:humoruniv/di/injection.dart';
import 'package:humoruniv/routes/app_router.dart';

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: HumorUnivApp()));
}

class HumorUnivApp extends StatelessWidget {
  const HumorUnivApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HumorUniv',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
