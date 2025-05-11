import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存管理器
/// 统一管理应用内存缓存、API响应缓存和持久化缓存
class CacheManager {
  /// 单例实例
  static final CacheManager _instance = CacheManager._();

  /// 工厂构造函数，返回单例实例
  factory CacheManager() => _instance;

  /// 私有构造函数
  CacheManager._();

  /// 内存缓存
  final Map<String, dynamic> _memoryCache = {};

  /// API响应缓存，带过期时间
  final Map<String, _CacheEntry> _apiCache = {};

  /// 获取内存缓存项
  T? getMemoryItem<T>(String key) {
    final item = _memoryCache[key];
    if (item is T) {
      return item;
    }
    return null;
  }

  /// 设置内存缓存项
  void setMemoryItem<T>(String key, T value) {
    _memoryCache[key] = value;
  }

  /// 移除内存缓存项
  void removeMemoryItem(String key) {
    _memoryCache.remove(key);
  }

  /// 清空内存缓存
  void clearMemoryCache() {
    _memoryCache.clear();
  }

  /// 获取API缓存项
  T? getApiCache<T>(String key) {
    final entry = _apiCache[key];
    if (entry == null || entry.isExpired) {
      _apiCache.remove(key);
      return null;
    }

    if (entry.data is T) {
      return entry.data as T;
    }
    return null;
  }

  /// 设置API缓存项，带过期时间
  void setApiCache<T>(
    String key,
    T value, {
    Duration expiration = const Duration(minutes: 5),
  }) {
    _apiCache[key] = _CacheEntry(
      data: value,
      expiryTime: DateTime.now().add(expiration),
    );
  }

  /// 清空API缓存
  void clearApiCache() {
    _apiCache.clear();
  }

  /// 清理过期的API缓存
  void cleanExpiredApiCache() {
    final keysToRemove = <String>[];

    _apiCache.forEach((key, entry) {
      if (entry.isExpired) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _apiCache.remove(key);
    }
  }

  /// 持久化存储数据
  Future<bool> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      return prefs.setString(key, value);
    } else if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else if (value is List<String>) {
      return prefs.setStringList(key, value);
    } else {
      // 尝试将对象序列化为JSON字符串
      try {
        final jsonString = jsonEncode(value);
        return prefs.setString(key, jsonString);
      } catch (e) {
        print('Error saving object to SharedPreferences: $e');
        return false;
      }
    }
  }

  /// 读取持久化数据
  Future<T?> loadData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return null;

    final value = prefs.get(key);
    if (value is T) {
      return value;
    } else if (T == dynamic && value is String) {
      // 尝试解析JSON
      try {
        return jsonDecode(value) as T?;
      } catch (e) {
        return value as T?;
      }
    }
    return null;
  }

  /// 删除持久化数据
  Future<bool> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  /// 清空所有持久化数据
  Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}

/// 缓存条目，包含数据和过期时间
class _CacheEntry {
  final dynamic data;
  final DateTime expiryTime;

  _CacheEntry({required this.data, required this.expiryTime});

  /// 检查缓存是否已过期
  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
