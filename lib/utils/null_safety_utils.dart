import 'package:text_sphere_app/utils/app_logger.dart';

/// 安全类型转换和空值处理工具类
class NullSafetyUtils {
  /// 安全地将任意值转换为字符串
  /// 如果值为null，返回默认值
  static String safeToString(dynamic value, {String defaultValue = ''}) {
    if (value == null) {
      return defaultValue;
    }
    return value.toString();
  }

  /// 安全地获取Map中的String值
  /// 如果值为null或非String类型，返回默认值
  static String safeMapString(
    Map<dynamic, dynamic>? map,
    String key, {
    String defaultValue = '',
  }) {
    if (map == null || !map.containsKey(key)) {
      return defaultValue;
    }

    var value = map[key];
    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  /// 安全地从动态数据结构中获取嵌套属性
  /// 例如: safeGet(data, ['user', 'profile', 'name'])
  static T? safeGet<T>(dynamic data, List<dynamic> keys, {T? defaultValue}) {
    if (data == null) {
      return defaultValue;
    }

    dynamic current = data;
    for (var key in keys) {
      if (current == null) {
        return defaultValue;
      }

      if (current is Map) {
        current = current[key];
      } else if (current is List && key is int && key < current.length) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }

    if (current == null) {
      return defaultValue;
    }

    try {
      return current as T;
    } catch (e) {
      logger.w('类型转换失败: 无法将 ${current.runtimeType} 转换为 $T');
      return defaultValue;
    }
  }

  /// 安全地尝试将任意值转换为指定类型
  /// 失败时返回默认值
  static T? safeCast<T>(dynamic value, {T? defaultValue}) {
    if (value == null) {
      return defaultValue;
    }

    try {
      if (value is T) {
        return value;
      }

      // 特殊处理String转换
      if (T == String) {
        return value.toString() as T;
      }

      // 特殊处理int转换
      if (T == int && value is String) {
        return int.tryParse(value) as T?;
      }

      // 特殊处理double转换
      if (T == double && value is String) {
        return double.tryParse(value) as T?;
      }

      // 特殊处理bool转换
      if (T == bool && value is String) {
        return (value.toLowerCase() == 'true') as T;
      }

      return defaultValue;
    } catch (e) {
      logger.w('类型转换失败: 无法将 ${value.runtimeType} 转换为 $T');
      return defaultValue;
    }
  }

  /// 记录类型转换异常并返回默认值
  static T handleConversionError<T>(
    dynamic value,
    String context,
    T defaultValue,
  ) {
    logger.e(
      '类型转换错误: 在 $context 中将 ${value?.runtimeType ?? 'null'} 转换为 $T',
      'value: $value',
    );
    return defaultValue;
  }
}
