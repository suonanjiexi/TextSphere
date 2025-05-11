import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 自定义页面过渡效果
class CustomTransitions extends CustomTransitionPage<void> {
  CustomTransitions({
    required Widget child,
    TransitionType transitionType = TransitionType.fadeWithSlide,
    LocalKey? key,
  }) : super(
         key: key,
         child: child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(
             context,
             animation,
             secondaryAnimation,
             child,
             transitionType,
           );
         },
       );

  /// 构建过渡效果
  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(
            opacity: CurveTween(curve: Curves.easeOut).animate(animation),
            child: child,
          ),
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(
            opacity: CurveTween(curve: Curves.easeOut).animate(animation),
            child: child,
          ),
        );

      case TransitionType.fadeWithSlide:
      default:
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
          child: SlideTransition(position: offsetAnimation, child: child),
        );
    }
  }
}

/// 过渡效果类型
enum TransitionType { fade, scale, slideUp, fadeWithSlide }
