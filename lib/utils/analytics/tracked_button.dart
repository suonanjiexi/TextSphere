import 'package:flutter/material.dart';
import 'user_action_tracker.dart';

/// 跟踪按钮组件
///
/// 自动记录用户点击行为的按钮组件
class TrackedButton extends StatelessWidget {
  final String buttonName;
  final String? screenName;
  final Map<String, dynamic>? properties;
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final bool? autofocus;
  final FocusNode? focusNode;
  final Clip? clipBehavior;

  /// 创建一个被跟踪的按钮
  const TrackedButton({
    Key? key,
    required this.buttonName,
    this.screenName,
    this.properties,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.autofocus = false,
    this.focusNode,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracker = UserActionTracker();
    return ElevatedButton(
      onPressed: () {
        // 记录按钮点击行为
        tracker.trackButtonClick(
          buttonName,
          screenName: screenName ?? ModalRoute.of(context)?.settings.name,
          properties: properties,
        );
        // 执行原有的点击回调
        onPressed();
      },
      onLongPress:
          onLongPress != null
              ? () {
                // 记录长按行为
                tracker.trackButtonClick(
                  '$buttonName-长按',
                  screenName:
                      screenName ?? ModalRoute.of(context)?.settings.name,
                  properties: properties,
                );
                // 执行原有的长按回调
                onLongPress!();
              }
              : null,
      style: style,
      autofocus: autofocus ?? false,
      focusNode: focusNode,
      clipBehavior: clipBehavior ?? Clip.none,
      child: child,
    );
  }
}

/// 跟踪图标按钮组件
///
/// 自动记录用户点击图标按钮的行为
class TrackedIconButton extends StatelessWidget {
  final String buttonName;
  final String? screenName;
  final Map<String, dynamic>? properties;
  final IconData icon;
  final double? iconSize;
  final Color? color;
  final VoidCallback onPressed;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? splashRadius;

  /// 创建一个被跟踪的图标按钮
  const TrackedIconButton({
    Key? key,
    required this.buttonName,
    this.screenName,
    this.properties,
    required this.icon,
    this.iconSize,
    this.color,
    required this.onPressed,
    this.tooltip,
    this.padding,
    this.alignment,
    this.splashRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracker = UserActionTracker();
    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      color: color,
      onPressed: () {
        // 记录按钮点击行为
        tracker.trackButtonClick(
          buttonName,
          screenName: screenName ?? ModalRoute.of(context)?.settings.name,
          properties: properties,
        );
        // 执行原有的点击回调
        onPressed();
      },
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8.0),
      alignment: alignment ?? Alignment.center,
      splashRadius: splashRadius,
    );
  }
}

/// 跟踪文本按钮组件
///
/// 自动记录用户点击文本按钮的行为
class TrackedTextButton extends StatelessWidget {
  final String buttonName;
  final String? screenName;
  final Map<String, dynamic>? properties;
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool? autofocus;
  final Clip? clipBehavior;

  /// 创建一个被跟踪的文本按钮
  const TrackedTextButton({
    Key? key,
    required this.buttonName,
    this.screenName,
    this.properties,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracker = UserActionTracker();
    return TextButton(
      onPressed: () {
        // 记录按钮点击行为
        tracker.trackButtonClick(
          buttonName,
          screenName: screenName ?? ModalRoute.of(context)?.settings.name,
          properties: properties,
        );
        // 执行原有的点击回调
        onPressed();
      },
      onLongPress:
          onLongPress != null
              ? () {
                // 记录长按行为
                tracker.trackButtonClick(
                  '$buttonName-长按',
                  screenName:
                      screenName ?? ModalRoute.of(context)?.settings.name,
                  properties: properties,
                );
                // 执行原有的长按回调
                onLongPress!();
              }
              : null,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior ?? Clip.none,
      child: child,
    );
  }
}
