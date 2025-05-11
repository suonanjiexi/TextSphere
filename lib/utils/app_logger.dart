import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:flutter/material.dart';

/// 日志级别枚举
enum LogLevel { debug, info, warning, error, fatal }

/// 全局日志工具类
class AppLogger {
  // 单例模式
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // 是否启用日志
  bool _enabled = true;
  // 当前日志级别
  LogLevel _minLevel = LogLevel.debug;
  // 是否显示调用栈
  bool _showStack = true;
  // 是否打印时间戳
  bool _showTimestamp = true;
  // 是否在生产环境打印日志
  bool _logInProduction = false;

  /// 初始化日志设置
  void init({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
    bool showStack = true,
    bool showTimestamp = true,
    bool logInProduction = false,
  }) {
    _enabled = enabled;
    _minLevel = minLevel;
    _showStack = showStack;
    _showTimestamp = showTimestamp;
    _logInProduction = logInProduction;
  }

  /// 检查是否应该打印日志
  bool _shouldLog(LogLevel level) {
    if (!_enabled) return false;
    if (!_logInProduction && kReleaseMode) return false;
    return level.index >= _minLevel.index;
  }

  /// 获取日志级别对应的标签
  String _getLevelTag(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return '📝 INFO';
      case LogLevel.warning:
        return '⚠️ WARNING';
      case LogLevel.error:
        return '❌ ERROR';
      case LogLevel.fatal:
        return '☠️ FATAL';
    }
  }

  /// 获取当前时间戳
  String _getTimestamp() {
    return DateTime.now().toString();
  }

  /// 获取调用栈信息
  String _getStackInfo() {
    final frames = Trace.current().frames;
    // 跳过前几帧，因为它们是日志工具类内部的调用
    final frame = frames.length > 3 ? frames[3] : frames.last;
    return '${frame.member} (${frame.uri.toString().split('/').last}:${frame.line})';
  }

  /// 构建日志消息
  String _buildMessage(LogLevel level, String message) {
    final buffer = StringBuffer();

    if (_showTimestamp) {
      buffer.write('[${_getTimestamp()}] ');
    }

    buffer.write('${_getLevelTag(level)}: $message');

    if (_showStack) {
      buffer.write('\n  at ${_getStackInfo()}');
    }

    return buffer.toString();
  }

  /// 打印日志的核心方法
  void _log(LogLevel level, String message) {
    if (_shouldLog(level)) {
      final formattedMessage = _buildMessage(level, message);

      switch (level) {
        case LogLevel.debug:
        case LogLevel.info:
          developer.log(formattedMessage);
          break;
        case LogLevel.warning:
          developer.log(formattedMessage, name: 'WARNING');
          break;
        case LogLevel.error:
        case LogLevel.fatal:
          developer.log(formattedMessage, name: 'ERROR');
          break;
      }
    }
  }

  /// 打印调试级别日志
  void d(String message) {
    _log(LogLevel.debug, message);
  }

  /// 打印信息级别日志
  void i(String message) {
    _log(LogLevel.info, message);
  }

  /// 打印警告级别日志
  void w(String message) {
    _log(LogLevel.warning, message);
  }

  /// 打印错误级别日志
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _log(
        LogLevel.error,
        '$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}',
      );
    } else {
      _log(LogLevel.error, message);
    }
  }

  /// 打印致命错误级别日志
  void f(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _log(
        LogLevel.fatal,
        '$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}',
      );
    } else {
      _log(LogLevel.fatal, message);
    }
  }

  /// 记录方法执行时间
  Future<T> logExecutionTime<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      i('$operationName 执行时间: ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      this.e(
        '$operationName 执行失败，耗时: ${stopwatch.elapsedMilliseconds}ms',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 统一异常处理
  Future<T> runGuarded<T>(
    Future<T> Function() function, {
    String? operationName,
    bool rethrowException = false,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      final opName = operationName ?? 'Operation';
      e('$opName 执行失败', error, stackTrace);

      if (rethrowException) {
        rethrow;
      }

      // 返回一个默认值或错误指示
      return Future<T>.error(error, stackTrace);
    }
  }
}

/// 全局日志单例
final logger = AppLogger();

/// 全局异常处理
class AppExceptionHandler {
  // 捕获并处理未捕获的Flutter错误
  static void init() {
    // 捕获Flutter框架中的错误
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.f('未捕获的Flutter错误', details.exception, details.stack);
      // 在调试模式仍然显示红屏错误
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // 捕获Zone中的错误
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.f('未捕获的平台错误', error, stack);
      return true; // 表示错误已处理
    };
  }

  // 处理特定类型的错误，并返回用户友好的消息
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FormatException) {
      return '数据格式错误，请稍后再试';
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return '网络连接错误，请检查您的网络设置';
    } else {
      return '发生了未知错误，请稍后再试';
    }
  }

  // 在UI上显示错误信息
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
