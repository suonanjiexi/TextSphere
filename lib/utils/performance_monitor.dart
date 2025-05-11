import 'dart:developer' as developer;
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// 应用性能监控工具
/// 用于监控和收集应用性能指标
class PerformanceMonitor {
  // 单例实现
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // 性能数据记录
  final Map<String, List<double>> _frameTimings = {};
  final Queue<FrameTiming> _recentFrames = Queue();
  final int _maxRecentFrames = 120; // 保存最近120帧

  // 是否已启动监控
  bool _isMonitoring = false;

  // 性能监控配置
  bool _showOverlay = false;

  // 页面导航计时
  final Map<String, int> _pageNavigationStartTimes = {};

  /// 启动性能监控
  void startMonitoring({bool showOverlay = false}) {
    if (_isMonitoring) return;

    _showOverlay = showOverlay;
    _isMonitoring = true;

    // 注册帧回调来监控帧渲染性能
    SchedulerBinding.instance.addPostFrameCallback(_onFrameEnd);

    // 启用性能覆盖层（可选）
    if (_showOverlay && kDebugMode) {
      WidgetsApp.showPerformanceOverlayOverride = true;
    }

    debugPrint('性能监控已启动');
  }

  /// 停止性能监控
  void stopMonitoring() {
    _isMonitoring = false;
    WidgetsApp.showPerformanceOverlayOverride = false;
    debugPrint('性能监控已停止');
  }

  /// 帧渲染结束回调
  void _onFrameEnd(Duration timeStamp) {
    if (!_isMonitoring) return;

    // 重新注册下一帧回调
    SchedulerBinding.instance.addPostFrameCallback(_onFrameEnd);

    // 获取最近帧的时间信息
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        _recentFrames.add(timing);
        // 保持队列长度不超过最大值
        while (_recentFrames.length > _maxRecentFrames) {
          _recentFrames.removeFirst();
        }

        // 计算渲染时间(毫秒)
        final buildTime = timing.buildDuration.inMicroseconds / 1000.0;
        final rasterTime = timing.rasterDuration.inMicroseconds / 1000.0;
        final totalFrameTime = buildTime + rasterTime;

        // 存储各项数据
        _addFrameTiming('build', buildTime);
        _addFrameTiming('raster', rasterTime);
        _addFrameTiming('total', totalFrameTime);

        // 输出帧信息(仅在调试模式且严重卡顿时)
        if (kDebugMode && totalFrameTime > 32.0) {
          // 32ms意味着低于30FPS
          debugPrint('⚠️ 卡顿帧检测: ${totalFrameTime.toStringAsFixed(2)}ms');
        }
      }
    });
  }

  /// 添加帧时间数据
  void _addFrameTiming(String key, double timeMs) {
    _frameTimings.putIfAbsent(key, () => []);
    _frameTimings[key]!.add(timeMs);

    // 控制列表大小
    if (_frameTimings[key]!.length > 300) {
      _frameTimings[key]!.removeAt(0);
    }
  }

  /// 获取平均帧率
  double getAverageFPS() {
    if (_recentFrames.isEmpty) return 60.0;

    // 计算最近帧的平均时间(秒)
    double avgFrameTimeSeconds = 0.0;
    for (final frame in _recentFrames) {
      avgFrameTimeSeconds +=
          (frame.totalSpan.inMicroseconds / 1000000.0) / _recentFrames.length;
    }

    // 计算FPS(帧/秒)
    return avgFrameTimeSeconds > 0 ? (1.0 / avgFrameTimeSeconds) : 60.0;
  }

  /// 开始页面导航计时
  void startPageNavigationTiming(String pageName) {
    _pageNavigationStartTimes[pageName] = DateTime.now().millisecondsSinceEpoch;
  }

  /// 结束页面导航计时并获取用时
  int endPageNavigationTiming(String pageName) {
    final startTime = _pageNavigationStartTimes[pageName];
    if (startTime == null) return 0;

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;

    _pageNavigationStartTimes.remove(pageName);
    return duration;
  }

  /// 测量代码执行时间
  static Future<T> measureExecutionTime<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();

      debugPrint('⏱️ $operationName 耗时: ${stopwatch.elapsedMilliseconds}ms');

      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ $operationName 失败，耗时: ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }

  /// 获取性能报告
  String getPerformanceReport() {
    final fps = getAverageFPS().toStringAsFixed(1);
    final buildTime = _getAverageFrameTiming('build').toStringAsFixed(1);
    final rasterTime = _getAverageFrameTiming('raster').toStringAsFixed(1);
    final totalTime = _getAverageFrameTiming('total').toStringAsFixed(1);

    final memoryInfo = _getMemoryInfo();

    return '''
性能报告：
平均帧率: $fps FPS
平均构建时间: $buildTime ms
平均光栅化时间: $rasterTime ms
平均总帧时间: $totalTime ms
内存使用: $memoryInfo
''';
  }

  /// 获取平均帧时间
  double _getAverageFrameTiming(String key) {
    final timings = _frameTimings[key];
    if (timings == null || timings.isEmpty) return 0.0;

    final sum = timings.reduce((a, b) => a + b);
    return sum / timings.length;
  }

  /// 获取内存使用信息
  String _getMemoryInfo() {
    if (kIsWeb) return "Web平台不支持";

    try {
      final memoryInfo = developer.Service.getInfo();
      return "查看Flutter DevTools获取详细信息";
    } catch (e) {
      return "无法获取内存信息";
    }
  }

  /// 记录UI卡顿
  void recordJank(String location, double durationMs) {
    if (durationMs >= 16.0) {
      final severity = durationMs >= 32.0 ? '严重' : '轻微';
      debugPrint(
        '卡顿($severity): $location - ${durationMs.toStringAsFixed(1)}ms',
      );
    }
  }

  /// 重置所有统计数据
  void resetStatistics() {
    _frameTimings.clear();
    _recentFrames.clear();
    _pageNavigationStartTimes.clear();
  }
}
