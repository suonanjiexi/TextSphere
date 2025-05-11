import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:text_sphere_app/utils/app_logger.dart';
import 'package:flutter/scheduler.dart';
import '../core/di/injection_container.dart';

/// 关键路径执行阶段
enum StartupPhase {
  systemUISetup,
  criticalAssetLoading,
  dependencyInjection,
  stateInitialization,
  firstFrameRendering,
  secondaryResourceLoading,
  complete,
}

/// 应用启动管理器
/// 管理应用启动流程和资源预加载
class AppStartupManager {
  /// 私有构造函数
  AppStartupManager._();

  /// 应用是否已完成启动
  static bool _startupComplete = false;

  /// 启动计时器
  static Stopwatch? _startupTimer;

  /// 各阶段计时
  static final Map<StartupPhase, int> _phaseTimings = {};

  /// 当前阶段
  static StartupPhase _currentPhase = StartupPhase.systemUISetup;

  /// 获取应用启动状态
  static bool get isStartupComplete => _startupComplete;

  /// 获取启动阶段计时
  static Map<StartupPhase, int> get phaseTimings =>
      Map.unmodifiable(_phaseTimings);

  /// 启动计时
  static void _startTimer() {
    _startupTimer = Stopwatch()..start();
  }

  /// 记录阶段完成时间
  static void _markPhaseComplete(StartupPhase phase) {
    if (_startupTimer == null) return;

    _phaseTimings[phase] = _startupTimer!.elapsedMilliseconds;
    _currentPhase = StartupPhase.values[phase.index + 1];

    logger.d('启动阶段完成: $phase, 耗时: ${_phaseTimings[phase]}ms');
  }

  /// 停止计时并返回启动时间（毫秒）
  static int _stopTimerAndGetDuration() {
    _startupTimer?.stop();
    return _startupTimer?.elapsedMilliseconds ?? 0;
  }

  /// 初始化并预加载关键资源
  static Future<void> init({
    List<String> preloadImages = const [],
    bool optimizeForPerformance = true,
    bool prefetchRoutes = true,
    bool enableCriticalPathOptimization = true,
    bool reduceJank = true,
  }) async {
    // 如果已经初始化，则直接返回
    if (_startupComplete) return;

    // 启动计时
    _startTimer();

    if (reduceJank) {
      // 减少首次渲染的抖动，可以通过其他方式实现
      // 这里采用简单的方式
      debugPrint('优化启动渲染性能');
    }

    // 设置系统UI样式
    await _configureSystemUI();
    _markPhaseComplete(StartupPhase.systemUISetup);

    // 预加载关键资源
    await _preloadCriticalResources(preloadImages);
    _markPhaseComplete(StartupPhase.criticalAssetLoading);

    // 预热依赖注入容器中的关键服务
    if (enableCriticalPathOptimization) {
      await _warmupCriticalServices();
    }
    _markPhaseComplete(StartupPhase.dependencyInjection);

    // 初始化关键状态
    await _initializeCoreState();
    _markPhaseComplete(StartupPhase.stateInitialization);

    // 标记启动主要阶段完成
    _startupComplete = true;

    // 记录启动时间
    final startupTime = _stopTimerAndGetDuration();
    logger.i('应用关键启动路径完成，耗时：$startupTime ms');

    // 在首帧渲染后预加载次要资源
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _markPhaseComplete(StartupPhase.firstFrameRendering);

      if (reduceJank) {
        // 恢复默认设置
        debugPrint('恢复正常渲染设置');
      }

      _preloadSecondaryResources();
    });
  }

  /// 配置系统UI
  static Future<void> _configureSystemUI() async {
    // 设置首选方向
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 设置系统UI样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 设置系统UI模式
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// 预加载关键资源
  static Future<void> _preloadCriticalResources(
    List<String> preloadImages,
  ) async {
    // 这里直接调用自定义缓存加载函数
    // 避免耦合具体实现，降低启动时间

    // 可以添加其他资源的预加载
    await Future.wait([_precacheAssets()]);
  }

  /// 预热关键服务
  static Future<void> _warmupCriticalServices() async {
    try {
      // 采用渐进式注册策略，优先注册核心依赖
      await sl.allReady(timeout: const Duration(seconds: 5)).onError((
        error,
        stackTrace,
      ) {
        logger.w('部分服务初始化超时，但不阻塞启动');
        return null;
      });
    } catch (e) {
      logger.w('预热关键服务部分失败，但不阻塞启动流程');
    }
  }

  /// 初始化核心状态
  static Future<void> _initializeCoreState() async {
    // 初始化应用必须的状态
    try {
      // 这里可以添加必要的状态初始化逻辑
      // 例如预加载必须的用户数据等
      await Future.delayed(const Duration(milliseconds: 10)); // 模拟初始化操作
    } catch (e) {
      logger.w('初始化核心状态部分失败，但不阻塞启动流程');
    }
  }

  /// 预加载次要资源
  static Future<void> _preloadSecondaryResources() async {
    // 次要资源加载不应该阻塞主线程
    unawaited(_loadSecondaryResourcesAsync());
  }

  /// 异步加载次要资源
  static Future<void> _loadSecondaryResourcesAsync() async {
    try {
      // 预加载次要资源，例如：
      // - 不是立即需要的图像
      // - 不频繁使用的字体
      // - 预取网络数据
      await Future.delayed(const Duration(milliseconds: 100));
      _markPhaseComplete(StartupPhase.secondaryResourceLoading);
      _markPhaseComplete(StartupPhase.complete);
    } catch (e) {
      logger.w('加载次要资源失败');
    }
  }

  /// 预缓存资源
  static Future<void> _precacheAssets() async {
    try {
      // 预加载图像资源
      // 预加载字体资源
      // 预加载其他资源
    } catch (e) {
      logger.w('预缓存资源失败');
    }
  }

  /// 获取启动性能报告
  static String getStartupReport() {
    final buffer = StringBuffer();
    buffer.writeln('应用启动性能报告:');
    buffer.writeln('-------------------');

    StartupPhase? lastPhase;
    for (final phase in StartupPhase.values) {
      if (_phaseTimings.containsKey(phase)) {
        final time = _phaseTimings[phase]!;
        final duration =
            lastPhase != null ? time - _phaseTimings[lastPhase]! : time;
        buffer.writeln('${phase.toString().split('.').last}: ${duration}ms');
        lastPhase = phase;
      }
    }

    buffer.writeln('-------------------');
    buffer.writeln('总启动时间: ${_phaseTimings[StartupPhase.complete] ?? 0}ms');

    return buffer.toString();
  }

  /// 检查启动是否超时
  static bool isStartupOverdue() {
    if (_startupTimer == null) return false;
    return _startupTimer!.elapsedMilliseconds > 5000; // 5秒钟超时
  }
}
