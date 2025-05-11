import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 响应式布局工具类
///
/// 提供屏幕自适应相关的工具方法，使应用在不同尺寸的设备上都能有良好的显示效果
class ResponsiveUtil {
  /// 获取屏幕宽度
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取屏幕高度
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 判断是否为小屏幕设备（宽度小于360dp）
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 360;
  }

  /// 判断是否为中等屏幕设备（宽度在360dp-400dp之间）
  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= 360 && screenWidth(context) < 400;
  }

  /// 判断是否为大屏幕设备（宽度大于等于400dp）
  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 400;
  }

  /// 计算自适应宽度比例
  static double widthFactor(BuildContext context) {
    return screenWidth(context) / 375.0;
  }

  /// 计算自适应高度比例
  static double heightFactor(BuildContext context) {
    return screenHeight(context) / 812.0;
  }

  /// 获取自适应的内边距
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
    } else if (isMediumScreen(context)) {
      return EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
    } else {
      return EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);
    }
  }

  /// 获取自适应的字体大小
  static double getAdaptiveFontSize(double fontSize) {
    return fontSize.sp;
  }

  /// 获取自适应的图标大小
  static double getAdaptiveIconSize(BuildContext context) {
    if (isSmallScreen(context)) {
      return 18.sp;
    } else if (isMediumScreen(context)) {
      return 22.sp;
    } else {
      return 24.sp;
    }
  }

  /// 获取自适应的按钮高度
  static double getAdaptiveButtonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 40.h;
    } else if (isMediumScreen(context)) {
      return 44.h;
    } else {
      return 48.h;
    }
  }

  /// 获取自适应的卡片边距
  static BorderRadius getAdaptiveRadius(BuildContext context) {
    if (isSmallScreen(context)) {
      return BorderRadius.circular(8.r);
    } else if (isMediumScreen(context)) {
      return BorderRadius.circular(12.r);
    } else {
      return BorderRadius.circular(16.r);
    }
  }
}
