import 'package:flutter/material.dart';
import 'package:humoruniv/core/widgets/organisms/bottom_nav_bar.dart';
import 'package:humoruniv/core/widgets/states/empty_state_view.dart';
import 'package:humoruniv/domain/entities/boards.dart';
import 'package:humoruniv/presentation/screens/board_screen.dart';
import 'package:humoruniv/presentation/screens/home_screen.dart';
import 'package:humoruniv/presentation/screens/settings_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  static const _titles = ['종합베스트', '웃긴자료', '검색', '설정'];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          BoardScreen(table: defaultBoard.table),
          const EmptyStateView(
            message: '검색 기능이 곧 추가됩니다',
            icon: Icons.search_outlined,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
