import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeOption { system, light, dark }

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.system:
        state = ThemeMode.system;
      case ThemeModeOption.light:
        state = ThemeMode.light;
      case ThemeModeOption.dark:
        state = ThemeMode.dark;
    }
  }
}
