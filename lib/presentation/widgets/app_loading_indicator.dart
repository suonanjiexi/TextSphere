import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/utils/responsive_utils.dart';

/// 应用加载指示器
///
/// 支持多种样式的加载指示器，针对不同场景优化性能
class AppLoadingIndicator extends StatelessWidget {
  /// 加载指示器类型
  final LoadingIndicatorType type;

  /// 指示器大小
  final double? size;

  /// 指示器颜色
  final Color? color;

  /// 背景色
  final Color? backgroundColor;

  /// 文本消息
  final String? message;

  /// 边距
  final EdgeInsetsGeometry? padding;

  /// 动画持续时间
  final Duration animationDuration;

  /// 指示器笔画宽度
  final double? strokeWidth;

  /// 是否显示背景
  final bool withBackground;

  /// 背景透明度
  final double backgroundOpacity;

  const AppLoadingIndicator({
    Key? key,
    this.type = LoadingIndicatorType.circular,
    this.size,
    this.color,
    this.backgroundColor,
    this.message,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.strokeWidth,
    this.withBackground = false,
    this.backgroundOpacity = 0.3,
  }) : super(key: key);

  /// 全屏加载指示器工厂构造函数
  factory AppLoadingIndicator.fullScreen({
    String? message,
    Color? color,
    Color? backgroundColor,
  }) {
    return AppLoadingIndicator(
      type: LoadingIndicatorType.circular,
      message: message,
      color: color,
      backgroundColor: backgroundColor,
      withBackground: true,
      backgroundOpacity: 0.7,
    );
  }

  /// 内联加载指示器工厂构造函数
  factory AppLoadingIndicator.inline({Color? color, double? size}) {
    return AppLoadingIndicator(
      type: LoadingIndicatorType.circular,
      size: size ?? 24,
      color: color,
      withBackground: false,
    );
  }

  /// 小型加载指示器工厂构造函数
  factory AppLoadingIndicator.small({Color? color}) {
    return AppLoadingIndicator(
      type: LoadingIndicatorType.circular,
      size: 16,
      color: color,
      strokeWidth: 2.0,
      withBackground: false,
    );
  }

  /// 按钮加载指示器工厂构造函数
  factory AppLoadingIndicator.button({Color? color, double? size}) {
    return AppLoadingIndicator(
      type: LoadingIndicatorType.circular,
      size: size ?? 20,
      color: color ?? Colors.white,
      strokeWidth: 2.0,
      withBackground: false,
    );
  }

  /// 自定义图标动画加载指示器工厂构造函数
  factory AppLoadingIndicator.customIcon({
    required LoadingIndicatorType type,
    Color? color,
    double? size,
  }) {
    return AppLoadingIndicator(
      type: type,
      size: size,
      color: color,
      withBackground: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

    // 确定指示器尺寸
    final effectiveSize = size ?? (isWideScreen ? 40.0 : 40.0.r);

    // 确定指示器颜色
    final effectiveColor = color ?? theme.colorScheme.primary;

    // 确定背景色
    final effectiveBackgroundColor =
        backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black : Colors.white);

    // 确定边距
    final effectivePadding =
        padding ??
        (isWideScreen ? const EdgeInsets.all(16) : EdgeInsets.all(16.r));

    // 确定笔画宽度
    final effectiveStrokeWidth = strokeWidth ?? 4.0;

    // 构建加载指示器
    Widget indicator;

    switch (type) {
      case LoadingIndicatorType.circular:
        indicator = SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CircularProgressIndicator(
            strokeWidth: effectiveStrokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );
        break;

      case LoadingIndicatorType.linear:
        indicator = SizedBox(
          width: effectiveSize * 5,
          height: effectiveSize / 4,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            backgroundColor: effectiveColor.withOpacity(0.2),
          ),
        );
        break;

      case LoadingIndicatorType.dots:
        indicator = _DotsLoadingIndicator(
          color: effectiveColor,
          size: effectiveSize,
          animationDuration: animationDuration,
        );
        break;

      case LoadingIndicatorType.bounce:
        indicator = _BounceLoadingIndicator(
          color: effectiveColor,
          size: effectiveSize,
          animationDuration: animationDuration,
        );
        break;

      case LoadingIndicatorType.pulse:
        indicator = _PulseLoadingIndicator(
          color: effectiveColor,
          size: effectiveSize,
          animationDuration: animationDuration,
        );
        break;
    }

    // 添加文本消息（如果有）
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: isWideScreen ? 16 : 16.h),
          Text(
            message!,
            style: TextStyle(
              color: effectiveColor,
              fontSize: isWideScreen ? 16 : 16.sp,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // 添加背景（如果需要）
    if (withBackground) {
      indicator = Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor.withOpacity(backgroundOpacity),
          borderRadius: BorderRadius.circular(isWideScreen ? 16 : 16.r),
        ),
        child: indicator,
      );
    }

    return Center(child: indicator);
  }
}

/// 加载指示器类型
enum LoadingIndicatorType {
  circular, // 圆形加载
  linear, // 线性加载
  dots, // 点动画
  bounce, // 弹跳动画
  pulse, // 脉冲动画
}

/// 点动画加载指示器
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const _DotsLoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // 创建3个动画控制器
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.animationDuration ~/ 2,
        vsync: this,
      );
    });

    // 创建缩放动画
    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // 按顺序启动动画
    _playAnimations();
  }

  void _playAnimations() async {
    // 错开动画播放时间
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.animationDuration ~/ 6);
      if (mounted) {
        _controllers[i].repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size / 4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: dotSize / 4),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// 弹跳动画加载指示器
class _BounceLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const _BounceLoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<_BounceLoadingIndicator> createState() =>
      _BounceLoadingIndicatorState();
}

class _BounceLoadingIndicatorState extends State<_BounceLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration ~/ 2,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 脉冲动画加载指示器
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const _PulseLoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.3),
          ),
          child: Center(
            child: Container(
              width: widget.size * _animation.value,
              height: widget.size * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
