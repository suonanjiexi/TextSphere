import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

/// 主题状态
class ThemeState extends Equatable {
  /// 主题模式
  final ThemeMode themeMode;

  /// 主题数据
  final ThemeData themeData;

  /// 主题颜色键
  final String themeColorKey;

  /// 构造函数
  const ThemeState({
    required this.themeMode,
    required this.themeData,
    this.themeColorKey = AppTheme.defaultThemeColorKey,
  });

  @override
  List<Object?> get props => [themeMode, themeData, themeColorKey];
}
