import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app_logger.dart';

/// 内存警告级别
enum MemoryWarningLevel {
  /// 正常
  normal,

  /// 轻度警告
  low,

  /// 严重警告
  critical,
}

/// 内存管理器
///
/// 提供对应用内存使用的监控和优化功能
class MemoryManager {
  // 单例实现
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  // 内存警告流
  final _memoryWarningController =
      StreamController<MemoryWarningLevel>.broadcast();

  // 最近一次内存使用量
  double _lastUsedMemoryMB = 0;

  // 是否已初始化
  bool _isInitialized = false;

  // 定时器
  Timer? _monitorTimer;

  // 内存警告流
  Stream<MemoryWarningLevel> get memoryWarnings =>
      _memoryWarningController.stream;

  // 最近一次内存使用量(MB)
  double get lastUsedMemoryMB => _lastUsedMemoryMB;

  /// 初始化内存管理器
  Future<void> init({
    Duration monitorInterval = const Duration(seconds: 10),
  }) async {
    if (_isInitialized) return;

    // 设置低内存回调（仅在Android上有效）
    if (Platform.isAndroid) {
      // 这里可以使用MethodChannel调用原生代码来设置内存警告回调
      const platform = MethodChannel('text_sphere_app/memory');
      try {
        platform.setMethodCallHandler((call) async {
          if (call.method == 'onMemoryWarning') {
            final level = call.arguments as int;
            _handleMemoryWarning(level);
          }
        });
        await platform.invokeMethod('registerMemoryWarningCallback');
      } catch (e) {
        logger.w('无法注册内存警告回调: $e');
      }
    }

    // 启动内存监控定时器
    _monitorTimer = Timer.periodic(monitorInterval, (_) {
      _checkMemoryUsage();
    });

    _isInitialized = true;
    logger.i('内存管理器初始化完成');
  }

  /// 处理来自操作系统的内存警告
  void _handleMemoryWarning(int level) {
    // 转换等级
    final warningLevel =
        level >= 15
            ? MemoryWarningLevel.critical
            : level >= 10
            ? MemoryWarningLevel.low
            : MemoryWarningLevel.normal;

    // 发送警告
    _memoryWarningController.add(warningLevel);

    // 根据警告级别采取措施
    _handleWarningLevel(warningLevel);
  }

  /// 检查内存使用情况
  Future<void> _checkMemoryUsage() async {
    try {
      final memInfo = await getMemoryInfo();
      _lastUsedMemoryMB = memInfo.usedMemoryMB;

      // 根据内存使用量判断警告级别
      MemoryWarningLevel warningLevel = MemoryWarningLevel.normal;
      if (memInfo.usedMemoryRatio > 0.85) {
        warningLevel = MemoryWarningLevel.critical;
      } else if (memInfo.usedMemoryRatio > 0.7) {
        warningLevel = MemoryWarningLevel.low;
      }

      // 发送警告
      if (warningLevel != MemoryWarningLevel.normal) {
        _memoryWarningController.add(warningLevel);
        _handleWarningLevel(warningLevel);
      }
    } catch (e) {
      logger.w('检查内存使用失败: $e');
    }
  }

  /// 处理不同级别的内存警告
  void _handleWarningLevel(MemoryWarningLevel level) {
    switch (level) {
      case MemoryWarningLevel.low:
        _cleanupLowPriorityResources();
        break;
      case MemoryWarningLevel.critical:
        _cleanupAllResources();
        break;
      default:
        break;
    }
  }

  /// 清理低优先级资源
  void _cleanupLowPriorityResources() {
    logger.i('内存警告(低): 清理低优先级资源');

    // 清理图片缓存
    PaintingBinding.instance.imageCache.clear();

    // 可以添加其他资源的清理逻辑
  }

  /// 清理所有可释放资源
  void _cleanupAllResources() {
    logger.i('内存警告(严重): 清理所有可释放资源');

    // 清理图片缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 强制执行垃圾回收
    // 注意: 这只是建议VM进行GC，不保证立即执行
    if (kReleaseMode == false) {
      // 仅在调试模式使用
      debugPrint('建议VM执行GC');
    }

    // 可以添加其他资源的清理逻辑
  }

  /// 获取当前内存使用信息
  Future<MemoryInfo> getMemoryInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      const platform = MethodChannel('text_sphere_app/memory');
      try {
        final result = await platform.invokeMethod('getMemoryInfo');
        return MemoryInfo.fromMap(result);
      } catch (e) {
        logger.w('获取内存信息失败: $e');
        // 返回模拟数据
        return MemoryInfo(
          totalMemoryMB: 1024,
          usedMemoryMB: 512,
          freeMemoryMB: 512,
        );
      }
    } else {
      // 在其他平台上返回模拟数据
      return MemoryInfo(
        totalMemoryMB: 1024,
        usedMemoryMB: 512,
        freeMemoryMB: 512,
      );
    }
  }

  /// 主动触发内存清理
  void cleanupMemory({bool aggressive = false}) {
    if (aggressive) {
      _cleanupAllResources();
    } else {
      _cleanupLowPriorityResources();
    }
  }

  /// 销毁资源
  void dispose() {
    _monitorTimer?.cancel();
    _memoryWarningController.close();
  }
}

/// 内存信息类
class MemoryInfo {
  /// 总内存 (MB)
  final double totalMemoryMB;

  /// 已使用内存 (MB)
  final double usedMemoryMB;

  /// 可用内存 (MB)
  final double freeMemoryMB;

  /// 构造函数
  MemoryInfo({
    required this.totalMemoryMB,
    required this.usedMemoryMB,
    required this.freeMemoryMB,
  });

  /// 内存使用率 (0-1)
  double get usedMemoryRatio => usedMemoryMB / totalMemoryMB;

  /// 从Map构造
  factory MemoryInfo.fromMap(Map<dynamic, dynamic> map) {
    return MemoryInfo(
      totalMemoryMB: (map['totalMemoryMB'] as num).toDouble(),
      usedMemoryMB: (map['usedMemoryMB'] as num).toDouble(),
      freeMemoryMB: (map['freeMemoryMB'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'MemoryInfo(总内存: ${totalMemoryMB.toStringAsFixed(2)}MB, '
        '已用: ${usedMemoryMB.toStringAsFixed(2)}MB, '
        '可用: ${freeMemoryMB.toStringAsFixed(2)}MB, '
        '使用率: ${(usedMemoryRatio * 100).toStringAsFixed(1)}%)';
  }
}
