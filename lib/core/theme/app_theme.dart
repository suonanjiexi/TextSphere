import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_sphere_app/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 应用主题
class AppTheme {
  AppTheme._();

  // 预设的主题颜色方案
  static const Map<String, ThemeColor> themeColors = {
    'purple': ThemeColor(
      name: '紫色',
      primary: Color(0xFF6750A4),
      secondary: Color(0xFF9A82DB),
      tertiary: Color(0xFFEFB8C8),
    ),
    'blue': ThemeColor(
      name: '蓝色',
      primary: Color(0xFF0061A4),
      secondary: Color(0xFF66B2FF),
      tertiary: Color(0xFFAEDEFF),
    ),
    'green': ThemeColor(
      name: '绿色',
      primary: Color(0xFF006C51),
      secondary: Color(0xFF4CDFB0),
      tertiary: Color(0xFFA0F4D0),
    ),
    'red': ThemeColor(
      name: '红色',
      primary: Color(0xFFBA1A1A),
      secondary: Color(0xFFFF8C8C),
      tertiary: Color(0xFFFFDAD6),
    ),
    'orange': ThemeColor(
      name: '橙色',
      primary: Color(0xFFE35A00),
      secondary: Color(0xFFFFB77C),
      tertiary: Color(0xFFFFDCC2),
    ),
  };

  // 默认主题颜色
  static const String defaultThemeColorKey = 'purple';

  // 静态主题数据实例
  static ThemeData? _lightTheme;
  static ThemeData? _darkTheme;

  // 主题初始化标记
  static bool _initialized = false;

  // 初始化方法，在ScreenUtilInit之后调用
  static void initialize() {
    if (!_initialized) {
      _lightTheme = _createLightTheme(defaultThemeColorKey);
      _darkTheme = _createDarkTheme(defaultThemeColorKey);
      _initialized = true;
      logger.i('AppTheme initialized successfully');
    }
  }

  // 获取轻主题，确保已初始化
  static ThemeData get lightTheme {
    if (!_initialized) {
      _lightTheme = _createLightTheme(defaultThemeColorKey);
      logger.w('获取lightTheme时AppTheme尚未初始化，已自动初始化');
    }
    return _lightTheme!;
  }

  // 获取暗主题，确保已初始化
  static ThemeData get darkTheme {
    if (!_initialized) {
      _darkTheme = _createDarkTheme(defaultThemeColorKey);
      logger.w('获取darkTheme时AppTheme尚未初始化，已自动初始化');
    }
    return _darkTheme!;
  }

  // 获取指定颜色的光主题
  static ThemeData getLightTheme({
    String themeColorKey = defaultThemeColorKey,
  }) {
    if (themeColorKey == defaultThemeColorKey && _initialized) {
      return lightTheme;
    }
    return _createLightTheme(themeColorKey);
  }

  // 获取指定颜色的暗主题
  static ThemeData getDarkTheme({String themeColorKey = defaultThemeColorKey}) {
    if (themeColorKey == defaultThemeColorKey && _initialized) {
      return darkTheme;
    }
    return _createDarkTheme(themeColorKey);
  }

  // 颜色定义 - 更新为更现代的颜色方案
  static Color primaryColor =
      themeColors[defaultThemeColorKey]!.primary; // Material 3 主色
  static Color secondaryColor =
      themeColors[defaultThemeColorKey]!.secondary; // 紫色次要色
  static Color tertiaryColor =
      themeColors[defaultThemeColorKey]!.tertiary; // Material 3 第三色
  static const Color accentColor = Color(0xFF03DAC6); // Material 3 强调色
  static const Color errorColor = Color(0xFFB3261E); // Material 3 错误色
  static const Color warningColor = Color(0xFFFFB93E);
  static const Color successColor = Color(0xFF21A179);

  // 文本颜色
  static const Color textPrimary = Color(0xFF1C1B1F); // Material 3 正文色
  static const Color textSecondary = Color(0xFF49454F); // Material 3 次要文本
  static const Color textLight = Color(0xFF79747E); // Material 3 浅色文本
  static const Color textOnPrimary = Colors.white; // 主色调上的文本

  // 背景颜色
  static const Color background = Color(0xFFFFFBFE); // Material 3 背景色
  static const Color surfaceColor = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Color(0xFFF7F2FA); // 轻微的紫色背景

  // 边框颜色
  static const Color borderColor = Color(0xFFE7E0EC); // Material 3边框色
  static const Color dividerColor = Color(0xFFE7E0EC);

  // 间距系统
  static double get spacing2 => 2.w;
  static double get spacing4 => 4.w;
  static double get spacing8 => 8.w;
  static double get spacing12 => 12.w;
  static double get spacing16 => 16.w;
  static double get spacing24 => 24.w;
  static double get spacing32 => 32.w;

  // 阴影
  static List<BoxShadow> get elevation1 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: val(8),
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevation2 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: val(10),
      offset: const Offset(0, 4),
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get elevation3 => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: val(14),
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  // 辅助方法 - 根据屏幕大小调整值
  static double val(double value) => value.r;

  // 圆角
  static BorderRadius get defaultRadius => BorderRadius.circular(16.r);
  static BorderRadius get smallRadius => BorderRadius.circular(10.r);
  static BorderRadius get largeRadius => BorderRadius.circular(24.r);
  static BorderRadius get roundedRadius => BorderRadius.circular(28.r);

  // 卡片装饰
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: defaultRadius,
    boxShadow: elevation1,
    border: Border.all(color: Colors.grey.withOpacity(0.05), width: 1),
  );

  // 按钮样式
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    shape: RoundedRectangleBorder(borderRadius: defaultRadius),
    textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    side: BorderSide(color: primaryColor, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: defaultRadius),
    textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    shape: RoundedRectangleBorder(borderRadius: smallRadius),
    textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w500),
  );

  // 图标按钮
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double? size,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(icon, color: color, size: size ?? 24.w),
      ),
    );
  }

  // 输入框装饰
  static InputDecoration inputDecoration({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffix,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffix: suffix,
      errorText: errorText,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      filled: true,
      fillColor: inputBackground,
      border: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: defaultRadius,
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
    );
  }

  // 标签页主题
  static final TabBarTheme tabBarTheme = TabBarTheme(
    labelColor: primaryColor,
    unselectedLabelColor: textSecondary,
    indicatorSize: TabBarIndicatorSize.label,
    indicatorColor: primaryColor,
    labelStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
    unselectedLabelStyle: bodyMedium,
  );

  // 文本样式
  static final TextStyle headingLarge = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static final TextStyle headingMedium = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static final TextStyle headingSmall = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  static final TextStyle titleLarge = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static final TextStyle titleMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static final TextStyle titleSmall = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static final TextStyle bodyLarge = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static final TextStyle bodyMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static final TextStyle bodySmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static final TextStyle labelLarge = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static final TextStyle labelMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static final TextStyle labelSmall = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // 辅助方法 - 获取颜色的更亮版本(用于暗色主题)
  static Color _getLighterColor(Color color) {
    // 将颜色转换为HSL，然后增加亮度
    HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor();
  }

  // 辅助方法 - 获取颜色的更暗版本
  static Color _getDarkerColor(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
  }

  // 更新主题颜色
  static void updateThemeColor(String colorKey) {
    final themeColor =
        themeColors[colorKey] ?? themeColors[defaultThemeColorKey]!;
    primaryColor = themeColor.primary;
    secondaryColor = themeColor.secondary;
    tertiaryColor = themeColor.tertiary;
  }

  // 创建光主题的实现
  static ThemeData _createLightTheme(String themeColorKey) {
    final themeColor =
        themeColors[themeColorKey] ?? themeColors[defaultThemeColorKey]!;
    // 首先更新静态颜色
    primaryColor = themeColor.primary;
    secondaryColor = themeColor.secondary;
    tertiaryColor = themeColor.tertiary;

    final primary = themeColor.primary;
    final secondary = themeColor.secondary;
    final tertiary = themeColor.tertiary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'NotoSansSC',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        background: background,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: headingSmall,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: primary,
        labelStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(borderRadius: smallRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.w500),
        unselectedLabelStyle: bodySmall,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: largeRadius),
        elevation: 3,
        backgroundColor: surfaceColor,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputBackground,
        selectedColor: primary.withOpacity(0.1),
        labelStyle: bodySmall,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: smallRadius),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        hintStyle: bodyMedium.copyWith(color: textLight),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.2),
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.12),
        trackHeight: 4.h,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          return primary;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          return primary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primary.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  // 创建暗主题的实现
  static ThemeData _createDarkTheme(String themeColorKey) {
    final themeColor =
        themeColors[themeColorKey] ?? themeColors[defaultThemeColorKey]!;
    // 首先更新静态颜色
    primaryColor = themeColor.primary;
    secondaryColor = themeColor.secondary;
    tertiaryColor = themeColor.tertiary;

    // 在暗色模式下，我们使用更亮的颜色变体
    final primary = _getLighterColor(themeColor.primary);
    final secondary = _getLighterColor(themeColor.secondary);
    final tertiary = themeColor.tertiary;

    const background = Color(0xFF1C1B1F); // MD3暗色背景
    const surface = Color(0xFF2B2930); // MD3暗色模式表面色

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: 'NotoSansSC',
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor.primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        background: background,
        surface: surface,
        error: const Color(0xFFF2B8B5), // MD3暗色模式错误色
        onPrimary: _getDarkerColor(themeColor.primary), // MD3暗色模式主色上文本
        onSecondary: const Color(0xFF332D41),
        onBackground: const Color(0xFFE6E1E5), // MD3暗色模式背景上文本
        onSurface: const Color(0xFFE6E1E5), // MD3暗色模式表面上文本
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: headingSmall.copyWith(color: Colors.white),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: primary,
        labelStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: _getDarkerColor(themeColor.primary),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(borderRadius: smallRadius),
          textStyle: bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.w500),
        unselectedLabelStyle: bodySmall,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF49454F),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFD0BCFF),
        foregroundColor: Color(0xFF381E72),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: largeRadius),
        elevation: 3,
        backgroundColor: Color(0xFF2B2930),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF49454F),
        selectedColor: Color(0xFFD0BCFF).withOpacity(0.2),
        labelStyle: bodySmall.copyWith(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: smallRadius),
      ),
      cardTheme: CardTheme(
        color: Color(0xFF2B2930),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF49454F),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: Color(0xFFD0BCFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: Color(0xFFF2B8B5), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: Color(0xFFF2B8B5), width: 1.5),
        ),
        hintStyle: bodyMedium.copyWith(color: Colors.white70),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Color(0xFFD0BCFF),
        inactiveTrackColor: Color(0xFFD0BCFF).withOpacity(0.2),
        thumbColor: Color(0xFFD0BCFF),
        overlayColor: Color(0xFFD0BCFF).withOpacity(0.12),
        trackHeight: 4.h,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          return Color(0xFFD0BCFF);
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          return Color(0xFFD0BCFF);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.withOpacity(0.4);
          }
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFD0BCFF);
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFD0BCFF).withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
    );
  }
}

/// 主题颜色类
class ThemeColor {
  final String name;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const ThemeColor({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
}
