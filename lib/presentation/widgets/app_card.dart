import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/utils/responsive_utils.dart';

/// 应用统一卡片组件
///
/// 性能优化:
/// 1. 使用const构造函数
/// 2. 使用RepaintBoundary隔离重绘区域
/// 3. 减少重建开销
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final bool hasShadow;
  final bool isHighlighted;
  final Color? shadowColor;
  final bool useRepaintBoundary;
  final Duration? animationDuration;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.hasShadow = true,
    this.isHighlighted = false,
    this.shadowColor,
    this.useRepaintBoundary = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

    // 确定边框圆角
    final effectiveBorderRadius =
        borderRadius ??
        (isWideScreen
            ? BorderRadius.circular(16)
            : BorderRadius.circular(16.r));

    // 确定内边距
    final effectivePadding =
        padding ??
        (isWideScreen ? const EdgeInsets.all(16) : EdgeInsets.all(16.r));

    // 确定外边距
    final effectiveMargin =
        margin ??
        (isWideScreen
            ? const EdgeInsets.only(bottom: 16)
            : EdgeInsets.only(bottom: 16.h));

    // 确定背景色
    final effectiveBackgroundColor = backgroundColor ?? theme.cardColor;

    // 确定阴影
    final effectiveShadowColor =
        shadowColor ??
        (theme.brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.black.withOpacity(0.08));

    // 确定阴影高度
    final effectiveElevation = elevation ?? (hasShadow ? 1.0 : 0.0);

    // 构建卡片内容
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        boxShadow:
            hasShadow
                ? [
                  BoxShadow(
                    color: effectiveShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ]
                : null,
      ),
      padding: effectivePadding,
      child: child,
    );

    // 应用动画（如果指定）
    if (animationDuration != null) {
      cardContent = AnimatedContainer(
        duration: animationDuration!,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: effectiveBorderRadius,
          boxShadow:
              hasShadow
                  ? [
                    BoxShadow(
                      color: effectiveShadowColor,
                      blurRadius: isHighlighted ? 15 : 10,
                      offset: const Offset(0, 2),
                      spreadRadius: isHighlighted ? 0 : -2,
                    ),
                  ]
                  : null,
        ),
        padding: effectivePadding,
        child: child,
      );
    }

    // 如果有点击事件，添加手势检测
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: cardContent,
      );
    }

    // 使用RepaintBoundary隔离重绘区域（如果需要）
    if (useRepaintBoundary) {
      cardContent = RepaintBoundary(child: cardContent);
    }

    // 应用外边距
    return Container(margin: effectiveMargin, child: cardContent);
  }
}

/// 列表项卡片
/// 针对列表优化的卡片组件
class AppListItemCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const AppListItemCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isHighlighted: isHighlighted,
      // 列表项使用轻量级配置
      hasShadow: false,
      elevation: 0,
      useRepaintBoundary: true,
      animationDuration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}

/// 内容卡片
/// 针对内容展示优化的卡片组件
class AppContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppContentCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      // 内容卡片使用更高质量的视觉效果
      hasShadow: true,
      elevation: 2,
      useRepaintBoundary: true,
      child: child,
    );
  }
}

/// 动作卡片
/// 针对可交互内容优化的卡片组件
class AppActionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback onTap;
  final bool isHighlighted;

  const AppActionCard({
    Key? key,
    required this.child,
    required this.onTap,
    this.padding,
    this.margin,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isHighlighted: isHighlighted,
      // 动作卡片使用动画效果增强交互体验
      hasShadow: true,
      elevation: isHighlighted ? 4 : 2,
      useRepaintBoundary: true,
      animationDuration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}
