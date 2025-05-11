import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/presentation/pages/followers_page.dart';
import 'package:text_sphere_app/presentation/pages/following_page.dart';
import 'package:text_sphere_app/presentation/pages/home_page.dart';
import 'package:text_sphere_app/presentation/pages/profile_page.dart';
import 'package:text_sphere_app/presentation/pages/chat_detail_page.dart';
import 'package:text_sphere_app/presentation/pages/user_search_page.dart';
import 'package:text_sphere_app/presentation/pages/circle_search_page.dart';
import 'package:text_sphere_app/core/di/injection_container.dart' as di;
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_bloc.dart';

class AppRouter {
  static const String home = 'home';
  static const String profile = 'profile';
  static const String chatDetail = 'chatDetail';
  static const String followers = 'followers';
  static const String followersUser = 'followersUser';
  static const String following = 'following';
  static const String followingUser = 'followingUser';
  static const String userSearch = 'userSearch';
  static const String circleSearch = 'circleSearch';

  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/home',
    routes: [
      GoRoute(
        name: home,
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: profile,
        path: '/profile/:userId?', // 保持可选，方便直接访问/profile
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          return ProfilePage(userId: userId);
        },
      ),
      GoRoute(
        name: chatDetail,
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '1';
          return ChatDetailPage(chatId: chatId);
        },
      ),
      // 粉丝列表 (当前用户)
      GoRoute(
        name: followers,
        path: '/followers',
        builder: (context, state) => FollowersPage(userId: null),
      ),
      // 粉丝列表 (指定用户)
      GoRoute(
        name: followersUser,
        path: '/followers/:userId',
        builder: (context, state) {
          // userId 必须存在，否则会匹配上面的 /followers
          final userId = state.pathParameters['userId']!;
          return FollowersPage(userId: userId);
        },
      ),
      // 关注列表 (当前用户)
      GoRoute(
        name: following,
        path: '/following',
        builder: (context, state) => FollowingPage(userId: null),
      ),
      // 关注列表 (指定用户)
      GoRoute(
        name: followingUser,
        path: '/following/:userId',
        builder: (context, state) {
          // userId 必须存在
          final userId = state.pathParameters['userId']!;
          return FollowingPage(userId: userId);
        },
      ),
      // 用户搜索页面
      GoRoute(
        name: userSearch,
        path: '/user/search',
        builder: (context, state) {
          print('在AppRouter中构建用户搜索页面');
          final searchBloc = di.sl<UserSearchBloc>();
          return UserSearchPage(searchBloc: searchBloc);
        },
      ),
      // 添加圈子搜索页面路由
      GoRoute(
        name: circleSearch,
        path: '/circle/:circleId/search',
        builder: (context, state) {
          // 安全获取路径参数和查询参数
          final circleId = state.pathParameters['circleId'] ?? '';

          // 尝试解码圈子名称，提供更健壮的参数处理
          String circleName = '圈子';
          try {
            final rawName = state.uri.queryParameters['circleName'];
            if (rawName != null && rawName.isNotEmpty) {
              circleName = Uri.decodeComponent(rawName);
            }
          } catch (e) {
            print('解析圈子名称参数失败: $e');
            // 使用默认名称，已在上面设置
          }

          print('构建搜索页面 - circleId: $circleId, circleName: $circleName');

          return CircleSearchPage(circleId: circleId, circleName: circleName);
        },
      ),
    ],
    observers: [GoRouterObserver()],
  );
}

// 用于监听路由事件的观察者
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('路由压栈: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('路由弹出: ${route.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('路由移除: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('路由替换: ${newRoute?.settings.name}');
  }
}
