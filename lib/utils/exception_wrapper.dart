import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_sphere_app/utils/app_logger.dart';
import 'package:text_sphere_app/utils/null_safety_utils.dart';
import 'dart:async';
import 'package:dartz/dartz.dart';
import '../core/error/failures.dart';

/// 异常包装器，用于捕获和诊断运行时异常
class ExceptionWrapper {
  /// 安全地运行可能抛出异常的代码
  /// 捕获异常并记录，然后返回默认值
  static T runSafely<T>(
    T Function() function,
    T defaultValue,
    String operation,
  ) {
    try {
      return function();
    } catch (e, stackTrace) {
      logger.e('运行 $operation 时发生异常', e, stackTrace);
      return defaultValue;
    }
  }

  /// 包装UI构建函数，捕获渲染异常
  static Widget wrapBuilder({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    Widget Function(Object, StackTrace)? fallback,
    String? errorMessage,
    Color backgroundColor = Colors.red,
  }) {
    try {
      return builder(context);
    } catch (e, stackTrace) {
      // 记录错误
      logger.e('UI构建异常', e, stackTrace);

      // 如果提供了fallback函数，使用它处理错误
      if (fallback != null) {
        return fallback(e, stackTrace);
      }

      // 在调试模式下重新抛出异常，以便显示红屏错误
      if (kDebugMode) {
        throw e;
      }

      // 生产环境显示友好的错误UI
      return Material(
        color: backgroundColor.withOpacity(0.1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage ?? '渲染内容时发生错误，请稍后再试',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
  }

  /// 特别处理类型转换错误
  static String safelyGetString(
    dynamic value, {
    String context = '未知上下文',
    String defaultValue = '',
  }) {
    try {
      if (value == null) {
        logger.w('类型安全警告: 在 $context 中接收到空值，使用默认值代替');
        return defaultValue;
      }
      return value.toString();
    } catch (e) {
      logger.e('获取字符串值异常', e);
      return defaultValue;
    }
  }

  /// 诊断可能的null断言错误
  static void diagnoseNullable<T>(
    T? value,
    String variableName, {
    String location = '未知',
  }) {
    if (value == null) {
      logger.w('空值警告: $location 中的 $variableName 为null');
    }
  }

  /// 增强版MediaQuery，处理可能的空上下文问题
  static MediaQueryData safeMediaQuery(BuildContext? context) {
    if (context == null) {
      logger.w('上下文为空，返回默认MediaQueryData');
      return const MediaQueryData();
    }

    try {
      return MediaQuery.of(context);
    } catch (e) {
      logger.e('获取MediaQuery异常', e);
      return const MediaQueryData();
    }
  }

  /// 安全地访问MediaQuery
  static Widget safeMediaQueryWidget(BuildContext context, Widget? child) {
    if (child == null) {
      logger.w('safeMediaQuery 收到空的child');
      return const SizedBox.shrink();
    }

    try {
      return MediaQuery(
        // 避免系统字体大小影响应用内字体大小
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: child,
      );
    } catch (e, stackTrace) {
      logger.e('MediaQuery处理异常', e, stackTrace);
      // 错误发生时返回原始child，避免应用崩溃
      return child;
    }
  }
}

/// 全局异常处理包装器
/// 提供统一的异常处理机制
class AppExceptionHandler {
  // 单例模式
  static final AppExceptionHandler _instance = AppExceptionHandler._internal();
  factory AppExceptionHandler() => _instance;
  AppExceptionHandler._internal();

  // 全局异常处理初始化
  static void init() {
    // Flutter框架错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.f('未捕获的Flutter错误', details.exception, details.stack);
    };

    // Zone错误处理
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.f('未捕获的平台错误', error, stack);
      return true;
    };
  }

  /// 运行代码块并捕获异常
  static Future<T> run<T>(
    Future<T> Function() function, {
    required BuildContext context,
    String? operationName,
    bool showErrorDialog = true,
    bool logError = true,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      if (logError) {
        logger.e('${operationName ?? "操作"}失败', error, stackTrace);
      }

      if (showErrorDialog && context.mounted) {
        _showErrorDialog(context, getUserFriendlyMessage(error));
      }

      rethrow;
    }
  }

  /// 运行可能产生Right或Left的函数，并自动处理错误
  static Future<T> runEither<T>(
    Future<Either<Failure, T>> Function() function, {
    required BuildContext context,
    String? operationName,
    bool showErrorDialog = true,
    T? defaultValue,
  }) async {
    try {
      final result = await function();
      return result.fold((failure) {
        if (showErrorDialog && context.mounted) {
          _showErrorDialog(context, failure.message);
        }
        if (defaultValue != null) {
          return defaultValue;
        }
        throw Exception(failure.message);
      }, (success) => success);
    } catch (error, stackTrace) {
      logger.e('${operationName ?? "操作"}执行失败', error, stackTrace);

      if (showErrorDialog && context.mounted) {
        _showErrorDialog(context, getUserFriendlyMessage(error));
      }

      if (defaultValue != null) {
        return defaultValue;
      }
      rethrow;
    }
  }

  /// 显示错误对话框
  static void _showErrorDialog(BuildContext context, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('出错了'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('确定'),
                ),
              ],
            ),
      );
    }
  }

  /// 获取用户友好的错误信息
  static String getUserFriendlyMessage(dynamic error) {
    if (error is ServerFailure) {
      return error.message;
    } else if (error is NetworkFailure) {
      return '网络连接问题，请检查您的网络设置';
    } else if (error is CacheFailure) {
      return '无法加载缓存数据';
    } else if (error is AuthFailure) {
      return '登录信息已过期，请重新登录';
    } else if (error is ValidationFailure) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return '无法连接到服务器，请稍后再试';
    } else if (error.toString().contains('TimeoutException')) {
      return '连接超时，请稍后再试';
    } else {
      return '发生了错误，请稍后再试';
    }
  }

  /// 显示错误提示条
  static void showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 显示成功提示条
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 错误恢复操作
  static Future<void> runRecoveryAction(
    BuildContext context,
    Future<void> Function() action,
    String errorMessage,
    String recoveryMessage,
  ) async {
    try {
      await action();
    } catch (e, stack) {
      logger.e(errorMessage, e, stack);

      if (context.mounted) {
        final shouldRetry = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('出错了'),
                content: Text('$errorMessage\n\n是否要尝试$recoveryMessage?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('重试'),
                  ),
                ],
              ),
        );

        if (shouldRetry == true && context.mounted) {
          await runRecoveryAction(
            context,
            action,
            errorMessage,
            recoveryMessage,
          );
        }
      }
    }
  }
}
