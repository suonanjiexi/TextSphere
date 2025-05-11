// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

import 'message_list_page.dart';
import 'square_page.dart';
import 'circle_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _pages = [
    const SquarePage(),
    const CirclePage(),
    const MessageListPage(),
    const ProfilePage(),
  ];

  // 包装页面内容
  Widget _buildPageContent(BuildContext context, Widget page) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 8.w), child: page);
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题
    final theme = Theme.of(context);

    // 创建NavigationDestination列表
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: Icon(
          Icons.dashboard_outlined,
          size: 24.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.dashboard,
          size: 24.w,
          color: AppTheme.primaryColor,
        ),
        label: '广场',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.group_outlined,
          size: 24.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.group,
          size: 24.w,
          color: AppTheme.primaryColor,
        ),
        label: '圈子',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.message_outlined,
          size: 24.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.message,
          size: 24.w,
          color: AppTheme.primaryColor,
        ),
        label: '消息',
      ),
      NavigationDestination(
        icon: Icon(
          Icons.person_outline,
          size: 24.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.person,
          size: 24.w,
          color: AppTheme.primaryColor,
        ),
        label: '我的',
      ),
    ];

    // 使用基本的Scaffold实现导航
    return Scaffold(
      body: _buildPageContent(context, _pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
