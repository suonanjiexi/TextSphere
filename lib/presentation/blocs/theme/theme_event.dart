import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 主题事件基类
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// 初始化主题事件
class InitializeTheme extends ThemeEvent {
  const InitializeTheme();
}

/// 更改主题事件
class ChangeTheme extends ThemeEvent {
  /// 目标主题模式
  final ThemeMode themeMode;

  const ChangeTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

/// 切换主题事件
class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

class SetTheme extends ThemeEvent {
  final bool isDark;

  const SetTheme({required this.isDark});

  @override
  List<Object> get props => [isDark];
}

class SetThemeColor extends ThemeEvent {
  final String colorKey;

  const SetThemeColor({required this.colorKey});

  @override
  List<Object> get props => [colorKey];
}
