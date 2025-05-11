import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 应用资源管理器
/// 集中管理应用中使用的资源路径、颜色和其他常量
class AppResources {
  /// 禁止实例化
  AppResources._();

  // 图片资源路径
  static const String logoPath = 'assets/images/app_logo.svg';
  static const String logoRoundedPath = 'assets/images/app_logo_rounded.svg';
  static const String placeholderPath = 'assets/images/placeholder.png';
  static const String errorImagePath = 'assets/images/error_image.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';

  // 颜色
  static const Color primaryColor = Color(0xFF4a62e9);
  static const Color secondaryColor = Color(0xFF6dd5ed);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color successColor = Color(0xFF43A047);
  static const Color infoColor = Color(0xFF039BE5);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // 尺寸统一管理
  static double get iconSizeSmall => 16.sp;
  static double get iconSizeMedium => 24.sp;
  static double get iconSizeLarge => 32.sp;

  // 动画时长
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
