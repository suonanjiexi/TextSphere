import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 布局常量类
/// 统一管理应用中的边距、大小等布局常量
class AppLayout {
  // 私有构造函数，防止实例化
  AppLayout._();

  // 边距
  static double get paddingXS => 4.w;
  static double get paddingS => 8.w;
  static double get paddingM => 16.w;
  static double get paddingL => 24.w;
  static double get paddingXL => 32.w;

  // 圆角
  static double get radiusXS => 4.r;
  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 24.r;

  // 卡片
  static double get cardElevation => 2.0;
  static double get cardElevationLarge => 4.0;

  // 边框
  static double get borderWidth => 1.0;
  static double get borderWidthThick => 2.0;

  // 间距
  static double get spacingXS => 4.h;
  static double get spacingS => 8.h;
  static double get spacingM => 16.h;
  static double get spacingL => 24.h;
  static double get spacingXL => 32.h;

  // 各类组件默认尺寸
  static double get buttonHeight => 48.h;
  static double get appBarHeight => 56.h;
  static double get bottomBarHeight => 64.h;
  static double get dialogWidth => 320.w;

  // 响应式布局断点
  static double get breakpointPhone => 600.w;
  static double get breakpointTablet => 960.w;
  static double get breakpointDesktop => 1280.w;
}
