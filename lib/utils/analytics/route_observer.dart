import 'package:flutter/material.dart';
import 'user_action_tracker.dart';

/// 路由观察器
///
/// 用于自动跟踪用户页面访问行为
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final UserActionTracker _tracker = UserActionTracker();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _trackPageView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _trackPageView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _trackPageView(previousRoute, isPop: true);
    }
  }

  void _trackPageView(PageRoute<dynamic> route, {bool isPop = false}) {
    final String? routeName = route.settings.name;
    final dynamic arguments = route.settings.arguments;

    if (routeName != null) {
      _tracker.trackPageView(
        routeName,
        properties: {
          'transition': isPop ? 'pop' : 'push',
          'arguments': arguments != null ? arguments.toString() : null,
        },
      );
    }
  }
}
