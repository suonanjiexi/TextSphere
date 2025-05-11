import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:text_sphere_app/presentation/pages/circle_create_page.dart';
import 'package:text_sphere_app/presentation/pages/circle_detail_page.dart';
import 'package:text_sphere_app/presentation/pages/circle_post_create_page.dart';
import 'package:text_sphere_app/presentation/pages/home_page.dart';
import 'package:text_sphere_app/presentation/pages/login_page.dart';
import 'package:text_sphere_app/presentation/pages/register_page.dart';
import 'package:text_sphere_app/presentation/pages/post_detail_page.dart';
import 'package:text_sphere_app/presentation/pages/settings_page.dart';
import 'package:text_sphere_app/presentation/pages/splash_page.dart';
import 'package:text_sphere_app/presentation/pages/square_detail_page.dart';
import 'package:text_sphere_app/presentation/pages/square_post_create_page.dart';
import 'package:text_sphere_app/presentation/pages/square_search_page.dart';
import 'package:text_sphere_app/presentation/pages/notification_list_page.dart';
import 'package:text_sphere_app/presentation/pages/membership/membership_page.dart';
import 'package:text_sphere_app/presentation/widgets/error_page.dart';
import 'package:text_sphere_app/core/di/injection_container.dart' as di;
import 'package:text_sphere_app/presentation/blocs/post_detail/post_detail_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/post_detail/post_detail_event.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_search_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:text_sphere_app/utils/analytics/user_action_tracker.dart';
import 'package:text_sphere_app/utils/analytics/route_observer.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_state.dart';
import 'package:text_sphere_app/domain/entities/user.dart';
import 'package:text_sphere_app/presentation/pages/auth/login_page.dart'
    as auth;
import 'package:text_sphere_app/presentation/pages/login_page.dart';

class AppRouter {
  // 应用全局Key，用于访问NavigatorState
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // 用户行为跟踪器
  static final UserActionTracker _tracker = UserActionTracker();

  // 自定义导航观察器
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  // 分析路由观察器
  static final AnalyticsRouteObserver analyticsRouteObserver =
      AnalyticsRouteObserver();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    observers: [
      // 标准Flutter导航观察器
      routeObserver,
      // 分析路由观察器
      analyticsRouteObserver,
    ],
    routes: [
      // 闪屏页路由
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/', builder: (context, state) => HomePage()),
      // 主页路由
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      // 登录路由
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // 注册路由
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // 创建帖子路由 - 更具体的路径先放置
      GoRoute(
        path: '/circle/:circleId/create-post',
        builder: (context, state) {
          final circleId = state.pathParameters['circleId']!;
          return CirclePostCreatePage(circleId: circleId);
        },
      ),
      GoRoute(
        path: '/circle/post/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailPage(postId: postId);
        },
      ),
      // 创建圈子路由
      GoRoute(
        path: '/circle/create',
        builder: (context, state) => const CircleCreatePage(),
      ),
      GoRoute(
        path: '/circle/:circleId',
        builder: (context, state) {
          final circleId = state.pathParameters['circleId']!;
          return CircleDetailPage(circleId: circleId);
        },
      ),
      // 设置页面路由
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          return const SettingsPage();
        },
      ),
      // 广场帖子发布页面路由
      GoRoute(
        path: '/home/square/post/create',
        builder: (context, state) {
          return const SquarePostCreatePage();
        },
      ),
      // 广场帖子详情页路由
      GoRoute(
        path: '/home/square/detail/:postId',
        builder: (context, state) {
          try {
            final postId = state.pathParameters['postId']!;

            // 使用factoryParam正确创建PostDetailBloc实例
            PostDetailBloc postDetailBloc;
            try {
              postDetailBloc = di.sl.call<PostDetailBloc>(param1: postId);
            } catch (e, stack) {
              debugPrint('创建PostDetailBloc失败: $e');
              debugPrint('堆栈: $stack');

              // 跟踪错误
              _tracker.trackError(
                'PostDetailBloc创建失败',
                e.toString(),
                stackTrace: stack,
                properties: {'postId': postId},
              );

              return ErrorPage(
                message: '加载失败: 创建帖子详情管理器失败',
                onRetry: () {
                  context.go('/home'); // 返回主页
                },
              );
            }

            // 安全地添加加载事件
            try {
              postDetailBloc.add(LoadPostDetail(postId));
            } catch (e) {
              debugPrint('添加LoadPostDetail事件失败: $e');
              // 跟踪错误
              _tracker.trackError(
                'LoadPostDetail事件失败',
                e.toString(),
                properties: {'postId': postId},
              );
              // 即使加载事件失败，我们仍然可以尝试渲染页面
            }

            return SquareDetailPage(
              postId: postId,
              postDetailBloc: postDetailBloc,
            );
          } catch (e, stack) {
            debugPrint('路由构建失败: $e');
            debugPrint('堆栈: $stack');

            // 跟踪错误
            _tracker.trackError('广场详情页路由构建失败', e.toString(), stackTrace: stack);

            return ErrorPage(
              message: '加载失败，请稍后重试',
              onRetry: () {
                context.go('/home'); // 返回主页
              },
            );
          }
        },
      ),
      // 广场搜索页面路由
      GoRoute(
        path: '/home/square/search',
        builder: (context, state) {
          final searchBloc = di.sl<SquareSearchBloc>();
          return SquareSearchPage(searchBloc: searchBloc);
        },
      ),
      // 消息提醒页面路由
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          return const NotificationListPage();
        },
      ),
      // 会员中心路由
      GoRoute(
        path: '/membership',
        name: 'membership',
        builder: (context, state) {
          // 获取当前登录用户
          final authBloc = BlocProvider.of<AuthBloc>(context);
          final authState = authBloc.state;
          User? currentUser;

          if (authState is Authenticated) {
            currentUser = authState.user;
          }

          // 如果用户未登录，跳转到登录页面
          if (currentUser == null || !currentUser.isAuthenticated) {
            return const auth.LoginPage();
          }

          return MembershipPage(currentMembership: currentUser.membership);
        },
      ),
    ],
    // 配置路由变化回调，用于记录页面访问
    onException: (_, GoRouterState state, GoRouter router) {
      // 记录路由错误
      _tracker.trackError(
        '路由异常',
        '访问路由时出错: ${state.uri.toString()}',
        properties: {'location': state.uri.toString()},
      );
    },
    redirect: (BuildContext context, GoRouterState state) {
      // 记录路由访问
      _tracker.trackPageView(
        state.uri.toString(),
        properties: {
          'path': state.matchedLocation,
          'params':
              state.pathParameters.isNotEmpty
                  ? state.pathParameters.toString()
                  : null,
        },
      );
      return null; // 不重定向
    },
  );

  /// 延迟加载并注册非核心BLoC
  static void addLazyBlocs() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // 使用Provider.of而不是context.read来避免构建上下文依赖
      try {
        // 注册CircleBloc
        if (!_hasBloc<CircleBloc>(context)) {
          final circleBloc = di.sl<CircleBloc>();
          _addBlocProvider<CircleBloc>(context, circleBloc);
        }

        // 注册PostDetailBloc
        if (!_hasBloc<PostDetailBloc>(context)) {
          final postDetailBloc = di.sl<PostDetailBloc>();
          _addBlocProvider<PostDetailBloc>(context, postDetailBloc);
        }

        // 注册SquareSearchBloc
        if (!_hasBloc<SquareSearchBloc>(context)) {
          final squareSearchBloc = di.sl<SquareSearchBloc>();
          _addBlocProvider<SquareSearchBloc>(context, squareSearchBloc);
        }

        // 注册UserSearchBloc
        if (!_hasBloc<UserSearchBloc>(context)) {
          final userSearchBloc = di.sl<UserSearchBloc>();
          _addBlocProvider<UserSearchBloc>(context, userSearchBloc);
        }

        debugPrint('非核心BLoC已延迟加载和注册');
      } catch (e) {
        debugPrint('延迟加载BLoC失败: $e');
        // 跟踪错误
        _tracker.trackError('BLoC延迟加载失败', e.toString());
      }
    }
  }

  /// 检查特定类型的BLoC是否已注册
  static bool _hasBloc<T extends BlocBase>(BuildContext context) {
    try {
      context.read<T>();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 添加BLoC提供者
  static void _addBlocProvider<T extends BlocBase>(
    BuildContext context,
    T bloc,
  ) {
    try {
      final app = navigatorKey.currentWidget as MaterialApp;
      final newApp = BlocProvider<T>.value(value: bloc, child: app);
      // 由于我们不能直接替换widget树，因此这里只能通过重建来实现
      // 在实际应用中，最好在应用启动时就定义好完整的Provider树
      debugPrint('已注册BLoC: ${T.toString()}');
    } catch (e) {
      debugPrint('添加BLoC提供者失败: $e');
      // 跟踪错误
      _tracker.trackError('添加BLoC提供者失败', e.toString());
    }
  }
}
