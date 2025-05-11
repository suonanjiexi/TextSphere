import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';

/// 按钮类型
enum AppButtonType {
  /// 主要按钮
  primary,

  /// 次要按钮
  secondary,

  /// 文本按钮
  text,
}

/// 自定义按钮
class AppButton extends StatelessWidget {
  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final AppButtonType type;

  /// 是否加载中
  final bool isLoading;

  /// 是否占满宽度
  final bool fullWidth;

  /// 按钮高度
  final double? height;

  /// 按钮宽度
  final double? width;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 前景色
  final Color? foregroundColor;

  /// 背景色
  final Color? backgroundColor;

  /// 文本样式
  final TextStyle? textStyle;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 构造函数
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
    this.width,
    this.prefixIcon,
    this.foregroundColor,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 根据类型确定样式
    ButtonStyle buttonStyle;
    Widget? loadingIndicator;

    switch (type) {
      case AppButtonType.primary:
        buttonStyle = _buildPrimaryStyle();
        loadingIndicator = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        );
        break;
      case AppButtonType.secondary:
        buttonStyle = _buildSecondaryStyle();
        loadingIndicator = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2.5,
          ),
        );
        break;
      case AppButtonType.text:
        buttonStyle = _buildTextStyle();
        loadingIndicator = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2.5,
          ),
        );
        break;
    }

    // 创建按钮
    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      margin: margin,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child:
              isLoading
                  ? loadingIndicator
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(prefixIcon, size: 20.r),
                        SizedBox(width: 8.w),
                      ],
                      Text(text),
                    ],
                  ),
        ),
      ),
    );
  }

  /// 构建主要按钮样式
  ButtonStyle _buildPrimaryStyle() {
    return AppTheme.primaryButtonStyle.copyWith(
      backgroundColor:
          backgroundColor != null
              ? MaterialStateProperty.all(backgroundColor)
              : null,
      foregroundColor:
          foregroundColor != null
              ? MaterialStateProperty.all(foregroundColor)
              : null,
      textStyle:
          textStyle != null ? MaterialStateProperty.all(textStyle) : null,
      shape:
          borderRadius != null
              ? MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: borderRadius!),
              )
              : null,
    );
  }

  /// 构建次要按钮样式
  ButtonStyle _buildSecondaryStyle() {
    return AppTheme.outlinedButtonStyle.copyWith(
      backgroundColor:
          backgroundColor != null
              ? MaterialStateProperty.all(backgroundColor)
              : MaterialStateProperty.all(Colors.transparent),
      foregroundColor:
          foregroundColor != null
              ? MaterialStateProperty.all(foregroundColor)
              : null,
      textStyle:
          textStyle != null ? MaterialStateProperty.all(textStyle) : null,
      shape:
          borderRadius != null
              ? MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: borderRadius!,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              )
              : null,
    );
  }

  /// 构建文本按钮样式
  ButtonStyle _buildTextStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor:
          foregroundColor != null
              ? MaterialStateProperty.all(foregroundColor)
              : MaterialStateProperty.all(AppTheme.primaryColor),
      textStyle:
          textStyle != null
              ? MaterialStateProperty.all(textStyle)
              : MaterialStateProperty.all(
                AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
      elevation: MaterialStateProperty.all(0),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? AppTheme.defaultRadius,
        ),
      ),
    );
  }
}
