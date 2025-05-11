import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFF9D9DFF);

  // 文本颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);

  // 背景颜色
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF5F6FA);
  static const Color chatBackground = Color(0xFFF6F8FA);
  static const Color surface = Colors.white;

  // 边框和分割线颜色
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color dividerColor = Color(0xFFF0F0F0);

  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // 阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // 圆角
  static final BorderRadius smallRadius = BorderRadius.circular(6.r);
  static final BorderRadius defaultRadius = BorderRadius.circular(12.r);
  static final BorderRadius largeRadius = BorderRadius.circular(20.r);
  static final BorderRadius fullRadius = BorderRadius.circular(999.r);

  // 文本样式
  static TextStyle headingLarge = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle headingMedium = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle headingSmall = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle buttonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // 输入框样式
  static InputDecoration inputDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textLight),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: textLight) : null,
      suffix: suffix,
      filled: true,
      fillColor: inputBackground,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  // 按钮样式
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: EdgeInsets.symmetric(vertical: 16.h),
    shape: RoundedRectangleBorder(borderRadius: defaultRadius),
    minimumSize: Size(double.infinity, 50.h),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: inputBackground,
    foregroundColor: primaryColor,
    elevation: 0,
    padding: EdgeInsets.symmetric(vertical: 16.h),
    shape: RoundedRectangleBorder(borderRadius: defaultRadius),
    minimumSize: Size(double.infinity, 50.h),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    side: BorderSide(color: borderColor, width: 1),
    padding: EdgeInsets.symmetric(vertical: 16.h),
    shape: RoundedRectangleBorder(borderRadius: defaultRadius),
    minimumSize: Size(double.infinity, 50.h),
  );

  // 卡片样式
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: defaultRadius,
    boxShadow: cardShadow,
  );

  // TabBar样式
  static TabBarTheme tabBarTheme = TabBarTheme(
    labelColor: primaryColor,
    unselectedLabelColor: textLight,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
    unselectedLabelStyle: bodyMedium,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );

  // 图标按钮样式
  static Widget iconButton({
    required IconData icon,
    required Function() onPressed,
    Color color = primaryColor,
    double? size,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        child: Icon(icon, color: color, size: size ?? 24.sp),
      ),
    );
  }

  // 分割线
  static Widget divider({double height = 1, double indent = 0}) {
    return Divider(
      height: height,
      thickness: 1,
      color: dividerColor,
      indent: indent,
      endIndent: indent,
    );
  }

  // 标签样式
  static Widget tag(String text, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (color ?? primaryColor).withOpacity(0.1),
        borderRadius: fullRadius,
      ),
      child: Text(
        text,
        style: bodySmall.copyWith(
          color: color ?? primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
