import 'package:flutter/material.dart';

/// 响应式工具类，提供屏幕尺寸相关的工具方法
class ResponsiveUtils {
  /// 宽屏判断 - 始终返回false (移除PC端适配)
  static bool isWideScreen(BuildContext context) {
    return false;
  }

  /// 大屏判断 - 始终返回false (移除PC端适配)
  static bool isLargeScreen(BuildContext context) {
    return false;
  }

  /// 小屏判断 - 始终返回true (移除PC端适配)
  static bool isSmallScreen(BuildContext context) {
    return true;
  }
}
