import 'package:flutter/material.dart';
import 'package:text_sphere_app/utils/performance_utils.dart';

/// 提供经过性能优化的Flutter组件
class PerformanceWidgets {
  // 私有构造函数防止实例化
  PerformanceWidgets._();

  /// 高性能图片
  /// 根据图片大小自动决定是否使用RepaintBoundary
  static Widget optimizedImage({
    required Widget child,
    required Size imageSize,
    bool forceRepaintBoundary = false,
  }) {
    final shouldUseRepaintBoundary =
        forceRepaintBoundary ||
        PerformanceUtils.shouldUseRepaintBoundary(imageSize);

    return shouldUseRepaintBoundary ? RepaintBoundary(child: child) : child;
  }

  /// 高性能列表项
  /// 自动处理重绘边界和保活策略
  static Widget optimizedListItem({
    required Widget child,
    required bool isComplexUI,
    bool addAutomaticKeepAlive = false,
  }) {
    Widget result = child;

    // 对复杂UI使用重绘边界
    if (isComplexUI) {
      result = RepaintBoundary(child: result);
    }

    // 如果需要保持状态
    if (addAutomaticKeepAlive) {
      result = _KeepAliveWidget(child: result);
    }

    return result;
  }

  /// 延迟构建的小组件
  /// 在滚动列表时减轻负担
  static Widget lazyWidget({
    required WidgetBuilder builder,
    Widget? placeholder,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _LazyWidget(
      builder: builder,
      placeholder: placeholder,
      delay: delay,
    );
  }

  /// 平滑淡入淡出组件
  /// 用于减少页面过渡时的卡顿
  static Widget smoothFadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return _SmoothFadeIn(child: child, duration: duration, curve: curve);
  }
}

/// 自动保活包装器
class _KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const _KeepAliveWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<_KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<_KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// 延迟构建的Widget实现
class _LazyWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final Widget? placeholder;
  final Duration delay;

  const _LazyWidget({
    Key? key,
    required this.builder,
    this.placeholder,
    required this.delay,
  }) : super(key: key);

  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  bool _isBuilt = false;
  Widget? _builtWidget;

  @override
  void initState() {
    super.initState();
    // 延迟构建实际内容
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _builtWidget = widget.builder(context);
          _isBuilt = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBuilt) {
      return _builtWidget!;
    }

    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// 平滑淡入组件实现
class _SmoothFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _SmoothFadeIn({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  State<_SmoothFadeIn> createState() => _SmoothFadeInState();
}

class _SmoothFadeInState extends State<_SmoothFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
