import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_event.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_state.dart';
import 'package:text_sphere_app/utils/app_logger.dart';

/// 主题Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// SharedPreferences实例
  final SharedPreferences sharedPreferences;

  /// 主题偏好键
  static const _themePreferenceKey = 'app_theme_mode';

  /// 主题颜色偏好键
  static const _themeColorPreferenceKey = 'app_theme_color_key';

  ThemeBloc({required this.sharedPreferences})
    : super(
        // 初始状态 - 不直接使用AppTheme的主题
        ThemeState(
          themeMode: ThemeMode.system,
          themeData: ThemeData.light(), // 使用临时默认主题
          themeColorKey: AppTheme.defaultThemeColorKey,
        ),
      ) {
    // 注册事件处理器
    on<InitializeTheme>(_onInitializeTheme);
    on<ChangeTheme>(_onChangeTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
    on<SetThemeColor>(_onSetThemeColor);
  }

  /// 初始化主题
  Future<void> _onInitializeTheme(
    InitializeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final themeMode = _getStoredThemeMode();
      final themeColorKey = _getStoredThemeColorKey();

      // 确保AppTheme的静态颜色被更新
      AppTheme.updateThemeColor(themeColorKey);

      // 传递themeColorKey来获取正确的ThemeData
      final themeData = _getThemeData(themeMode, themeColorKey);

      emit(
        ThemeState(
          themeMode: themeMode,
          themeData: themeData,
          themeColorKey: themeColorKey,
        ),
      );

      // 应用系统样式
      _applySystemOverlayStyle(themeData);

      logger.i('主题初始化完成，模式: $themeMode, 颜色: $themeColorKey');
    } catch (e) {
      logger.e('主题初始化失败: $e');
      // 使用默认主题作为后备
      final fallbackThemeKey = AppTheme.defaultThemeColorKey;
      AppTheme.updateThemeColor(
        fallbackThemeKey,
      ); // Ensure static color updated
      emit(
        ThemeState(
          themeMode: ThemeMode.system,
          themeData: AppTheme.getLightTheme(themeColorKey: fallbackThemeKey),
          themeColorKey: fallbackThemeKey,
        ),
      );
    }
  }

  /// 更改主题模式 (ChangeTheme event is unused currently)
  void _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) {
    try {
      final newThemeMode = event.themeMode;
      final colorKey = state.themeColorKey; // Use current color key
      AppTheme.updateThemeColor(colorKey); // Ensure static color updated
      final newThemeData = _getThemeData(newThemeMode, colorKey);

      // 保存偏好
      _saveThemeMode(newThemeMode);

      emit(
        ThemeState(
          themeMode: newThemeMode,
          themeData: newThemeData,
          themeColorKey: colorKey, // Keep current color key
        ),
      );

      // 应用系统样式
      _applySystemOverlayStyle(newThemeData);

      logger.i('主题已更改为: $newThemeMode');
    } catch (e) {
      logger.e('更改主题失败: $e');
    }
  }

  /// 切换主题模式 (Light/Dark/System)
  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    try {
      // 在明暗主题之间切换
      final currentMode = state.themeMode;
      final colorKey = state.themeColorKey; // Use current color key
      ThemeMode newMode;

      if (currentMode == ThemeMode.system) {
        // If system, check actual brightness to decide next step reliably
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        newMode =
            brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      } else if (currentMode == ThemeMode.light) {
        newMode = ThemeMode.dark;
      } else {
        // currentMode == ThemeMode.dark
        newMode =
            ThemeMode
                .light; // Changed logic: Toggle between light and dark directly
      }

      AppTheme.updateThemeColor(colorKey); // Ensure static color updated
      final newThemeData = _getThemeData(newMode, colorKey);

      // 保存偏好
      _saveThemeMode(newMode);

      emit(
        ThemeState(
          themeMode: newMode,
          themeData: newThemeData,
          themeColorKey: colorKey, // Keep current color key
        ),
      );

      // 应用系统样式
      _applySystemOverlayStyle(newThemeData);

      logger.i('主题已切换为: $newMode');
    } catch (e) {
      logger.e('切换主题失败: $e');
    }
  }

  /// 处理设置主题模式事件 (Light/Dark)
  void _onSetTheme(SetTheme event, Emitter<ThemeState> emit) {
    try {
      final newThemeMode = event.isDark ? ThemeMode.dark : ThemeMode.light;
      final colorKey = state.themeColorKey; // Use current color key
      AppTheme.updateThemeColor(colorKey); // Ensure static color updated
      final newThemeData = _getThemeData(newThemeMode, colorKey);

      // 保存偏好
      _saveThemeMode(newThemeMode);

      emit(
        ThemeState(
          themeMode: newThemeMode,
          themeData: newThemeData,
          themeColorKey: colorKey, // Keep current color key
        ),
      );

      // 应用系统样式
      _applySystemOverlayStyle(newThemeData);

      logger.i('主题已更改为: ${event.isDark ? '深色' : '浅色'}');
    } catch (e) {
      logger.e('更改主题失败: $e');
    }
  }

  /// 处理设置主题颜色事件
  void _onSetThemeColor(SetThemeColor event, Emitter<ThemeState> emit) {
    try {
      final colorKey = event.colorKey;

      // 更新AppTheme中的静态颜色
      AppTheme.updateThemeColor(colorKey);

      // 获取使用新颜色生成的ThemeData
      final newThemeData = _getThemeData(state.themeMode, colorKey);

      // 保存偏好
      _saveThemeColorKey(colorKey);

      emit(
        ThemeState(
          themeMode: state.themeMode,
          themeData: newThemeData, // 使用新的ThemeData
          themeColorKey: colorKey, // 使用新的颜色Key
        ),
      );

      // 使用新的ThemeData应用系统样式
      _applySystemOverlayStyle(newThemeData);

      logger.i('主题颜色已更改为: $colorKey');
    } catch (e) {
      logger.e('更改主题颜色失败: $e');
    }
  }

  /// 保存主题模式
  Future<void> _saveThemeMode(ThemeMode mode) async {
    String value;

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }

    await sharedPreferences.setString(_themePreferenceKey, value);
  }

  /// 保存主题颜色键
  Future<void> _saveThemeColorKey(String colorKey) async {
    await sharedPreferences.setString(_themeColorPreferenceKey, colorKey);
  }

  /// 获取存储的主题模式
  ThemeMode _getStoredThemeMode() {
    final storedValue = sharedPreferences.getString(_themePreferenceKey);

    if (storedValue == null) {
      return ThemeMode.system;
    }

    switch (storedValue) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 获取存储的主题颜色偏好
  String _getStoredThemeColorKey() {
    return sharedPreferences.getString(_themeColorPreferenceKey) ??
        AppTheme.defaultThemeColorKey;
  }

  /// 根据主题模式获取主题数据 (需要传入颜色Key)
  ThemeData _getThemeData(ThemeMode mode, String themeColorKey) {
    switch (mode) {
      case ThemeMode.light:
        // 使用 getLightTheme 并传入颜色 Key
        return AppTheme.getLightTheme(themeColorKey: themeColorKey);
      case ThemeMode.dark:
        // 使用 getDarkTheme 并传入颜色 Key
        return AppTheme.getDarkTheme(themeColorKey: themeColorKey);
      case ThemeMode.system:
        // 根据系统亮度获取相应主题
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        // 使用 getDarkTheme/getLightTheme 并传入颜色 Key
        return brightness == Brightness.dark
            ? AppTheme.getDarkTheme(themeColorKey: themeColorKey)
            : AppTheme.getLightTheme(themeColorKey: themeColorKey);
    }
  }

  /// 应用系统样式
  void _applySystemOverlayStyle(ThemeData themeData) {
    final isDark = themeData.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: themeData.colorScheme.background, // 使用主题背景色
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
