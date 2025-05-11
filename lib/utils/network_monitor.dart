import 'package:dio/dio.dart';
import 'package:text_sphere_app/utils/app_logger.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 网络类型枚举
enum NetworkType { wifi, mobile, ethernet, none }

/// 网络质量枚举
enum NetworkQuality { excellent, good, fair, poor }

/// 网络请求监控工具，用于性能分析和异常捕获
class NetworkMonitor {
  // 单例实现
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal() {
    _initConnectivity();
  }

  final Dio _dio = Dio();

  // 当前网络类型
  NetworkType _currentNetworkType = NetworkType.wifi;
  // 当前网络质量
  NetworkQuality _currentNetworkQuality = NetworkQuality.good;

  // 获取当前网络类型
  NetworkType get currentNetworkType => _currentNetworkType;
  // 获取当前网络质量
  NetworkQuality get currentNetworkQuality => _currentNetworkQuality;

  // 初始化网络监控
  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      // 更新为接收列表参数
      _updateNetworkType(
        results.isNotEmpty ? results.first : ConnectivityResult.none,
      );
    });

    // 获取初始网络状态
    Connectivity().checkConnectivity().then((results) {
      // 更新为处理列表结果
      _updateNetworkType(
        results.isNotEmpty ? results.first : ConnectivityResult.none,
      );
    });
  }

  // 根据连接结果更新网络类型
  void _updateNetworkType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        _currentNetworkType = NetworkType.wifi;
        break;
      case ConnectivityResult.mobile:
        _currentNetworkType = NetworkType.mobile;
        break;
      case ConnectivityResult.ethernet:
        _currentNetworkType = NetworkType.ethernet;
        break;
      case ConnectivityResult.none:
      default:
        _currentNetworkType = NetworkType.none;
        break;
    }

    logger.d('网络类型变更为: $_currentNetworkType');
    _checkNetworkQuality();
  }

  // 检查网络质量
  Future<void> _checkNetworkQuality() async {
    // 如果没有网络连接，设置为最低质量
    if (_currentNetworkType == NetworkType.none) {
      _currentNetworkQuality = NetworkQuality.poor;
      return;
    }

    try {
      final startTime = DateTime.now().millisecondsSinceEpoch;
      final response = await _dio.get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final latency = endTime - startTime;

      // 根据延迟时间判断网络质量
      if (latency < 300) {
        _currentNetworkQuality = NetworkQuality.excellent;
      } else if (latency < 1000) {
        _currentNetworkQuality = NetworkQuality.good;
      } else if (latency < 3000) {
        _currentNetworkQuality = NetworkQuality.fair;
      } else {
        _currentNetworkQuality = NetworkQuality.poor;
      }

      logger.d('网络质量检测完成，延迟: ${latency}ms, 质量: $_currentNetworkQuality');
    } catch (e) {
      // 请求失败，设置为较低质量
      _currentNetworkQuality = NetworkQuality.poor;
      logger.d('网络质量检测失败，设置为: $_currentNetworkQuality');
    }
  }

  /// 手动触发网络质量检测
  Future<NetworkQuality> checkCurrentNetworkQuality() async {
    await _checkNetworkQuality();
    return _currentNetworkQuality;
  }

  /// 注册到Dio实例
  static void setupDioInstance(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requestId =
              DateTime.now().millisecondsSinceEpoch.toString() +
              (1000 + DateTime.now().microsecond % 9000).toString();
          options.extra['requestId'] = requestId;
          options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;

          logger.d(
            '[API请求开始] ID:$requestId URL:${options.uri} 方法:${options.method}',
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final requestId = response.requestOptions.extra['requestId'] ?? '';
          final startTime = response.requestOptions.extra['startTime'] ?? 0;
          final endTime = DateTime.now().millisecondsSinceEpoch;
          final duration = endTime - (startTime as int);

          logger.d(
            '[API请求成功] ID:$requestId 耗时:${duration}ms 状态码:${response.statusCode}',
          );

          // 性能警告
          if (duration > 1000) {
            logger.w('[API性能警告] 请求ID:$requestId 耗时过长: ${duration}ms');
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final requestId = error.requestOptions.extra['requestId'] ?? '';
          final startTime = error.requestOptions.extra['startTime'] ?? 0;
          final endTime = DateTime.now().millisecondsSinceEpoch;
          final duration = endTime - (startTime as int);

          logger.e(
            '[API请求失败] ID:$requestId 耗时:${duration}ms 方法:${error.requestOptions.method} '
            'URL:${error.requestOptions.uri}',
            error,
            error.stackTrace,
          );

          return handler.next(error);
        },
      ),
    );
  }
}
