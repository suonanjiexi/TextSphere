import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 可以控制ParabolicFab的控制器，便于从父组件控制显示/隐藏
class ParabolicFabController {
  _ParabolicFabState? _fabState;

  void _attach(_ParabolicFabState state) {
    _fabState = state;
  }

  void _detach() {
    _fabState = null;
  }

  void hideFab() {
    _fabState?.hideFab();
  }

  void showFab() {
    _fabState?.showFab();
  }
}

class ParabolicFab extends StatefulWidget {
  /// 按钮点击回调函数
  final VoidCallback? onPressed;

  /// 按钮图标
  final IconData iconData;

  /// 图标大小
  final double? iconSize;

  /// 按钮背景色
  final Color? backgroundColor;

  /// 图标颜色
  final Color? iconColor;

  /// 右侧位置偏移
  final double? rightOffset;

  /// 底部位置偏移
  final double? bottomOffset;

  /// 路由路径（如果提供此参数，点击会跳转到该路径）
  final String? routePath;

  /// 动画持续时间
  final Duration animationDuration;

  /// 控制器
  final ParabolicFabController? controller;

  const ParabolicFab({
    Key? key,
    this.onPressed,
    required this.iconData,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
    this.rightOffset,
    this.bottomOffset,
    this.routePath,
    this.animationDuration = const Duration(milliseconds: 500),
    this.controller,
  }) : super(key: key);

  @override
  State<ParabolicFab> createState() => _ParabolicFabState();
}

class _ParabolicFabState extends State<ParabolicFab>
    with SingleTickerProviderStateMixin {
  // 控制悬浮按钮显示/隐藏的动画控制器
  late AnimationController _fabController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();

    // 初始化FAB动画控制器
    _fabController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 0.0, // 初始状态为显示(0.0表示在屏幕内)
    );

    // 注册控制器
    if (widget.controller != null) {
      widget.controller!._attach(this);
    }
  }

  @override
  void didUpdateWidget(ParabolicFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果控制器发生变化，需要重新注册
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    // 解除控制器绑定
    widget.controller?._detach();
    _fabController.dispose();
    super.dispose();
  }

  /// 隐藏FAB的方法
  void hideFab() {
    if (_isFabVisible) {
      _fabController.animateTo(1.0, curve: Curves.easeOutQuart);
      setState(() {
        _isFabVisible = false;
      });
    }
  }

  /// 显示FAB的方法
  void showFab() {
    if (!_isFabVisible) {
      _fabController.animateTo(0.0, curve: Curves.elasticOut);
      setState(() {
        _isFabVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 不再直接返回Positioned，而是返回一个普通Widget
    return SlideTransition(
      position: TweenSequence<Offset>([
        // 第一阶段：开始向右上方移动（形成抛物线上升段）
        TweenSequenceItem(
          tween: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(0.5, -0.8), // 向右上方移动
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 40.0,
        ),
        // 第二阶段：继续向右方和下方移动（形成抛物线下降段）
        TweenSequenceItem(
          tween: Tween<Offset>(
            begin: Offset(0.5, -0.8),
            end: Offset(1.8, 0.5), // 向右下方移动
          ).chain(CurveTween(curve: Curves.easeOutQuad)),
          weight: 60.0,
        ),
      ]).animate(_fabController),
      child: FloatingActionButton(
        onPressed: () {
          if (widget.routePath != null) {
            context.push(widget.routePath!);
          }
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        elevation: 3,
        backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: widget.iconColor ?? theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          widget.iconData,
          color: widget.iconColor ?? theme.colorScheme.onPrimary,
          size: widget.iconSize ?? 28.sp,
        ),
      ),
    );
  }
}
