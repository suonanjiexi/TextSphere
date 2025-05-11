import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 网络类型枚举
enum NetworkType {
  /// 无网络连接
  none,

  /// 移动网络连接
  mobile,

  /// WiFi网络连接
  wifi,

  /// 以太网连接
  ethernet,

  /// 蓝牙网络连接
  bluetooth,

  /// VPN网络连接
  vpn,

  /// 其他类型网络连接
  other,
}

/// 网络质量状态枚举
enum NetworkQuality {
  /// 未知网络质量
  unknown,

  /// 差网络质量
  poor,

  /// 一般网络质量
  moderate,

  /// 良好网络质量
  good,

  /// 优秀网络质量
  excellent,
}

/// 智能网络管理类
class NetworkManager {
  /// 单例实例
  static final NetworkManager _instance = NetworkManager._();

  /// 工厂构造函数，返回单例实例
  factory NetworkManager() => _instance;

  /// 私有构造函数
  NetworkManager._() {
    _init();
  }

  /// Dio实例
  final Dio _dio = Dio();

  /// 连接性检查实例
  final Connectivity _connectivity = Connectivity();

  /// 当前网络类型
  NetworkType _currentNetworkType = NetworkType.none;

  /// 当前网络质量
  NetworkQuality _currentNetworkQuality = NetworkQuality.unknown;

  /// 网络类型变化流
  late StreamSubscription _connectivitySubscription;

  /// 网络类型变化控制器
  final StreamController<NetworkType> _networkTypeController =
      StreamController<NetworkType>.broadcast();

  /// 网络质量变化控制器
  final StreamController<NetworkQuality> _networkQualityController =
      StreamController<NetworkQuality>.broadcast();

  /// 获取当前网络类型
  NetworkType get currentNetworkType => _currentNetworkType;

  /// 获取当前网络质量
  NetworkQuality get currentNetworkQuality => _currentNetworkQuality;

  /// 获取网络类型变化流
  Stream<NetworkType> get onNetworkTypeChanged => _networkTypeController.stream;

  /// 获取网络质量变化流
  Stream<NetworkQuality> get onNetworkQualityChanged =>
      _networkQualityController.stream;

  /// 初始化网络管理器
  void _init() {
    // 配置Dio
    _configureDio();

    // 监听网络变化 - 使用正确的回调类型
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      dynamic result,
    ) {
      _handleConnectivityResult(result);
    });

    // 获取初始网络类型
    _connectivity.checkConnectivity().then((dynamic result) {
      _handleConnectivityResult(result);
    });

    // 定期检查网络质量
    Timer.periodic(const Duration(minutes: 5), (_) {
      _checkNetworkQuality();
    });
  }

  /// 处理连接性结果
  void _handleConnectivityResult(dynamic result) {
    // 处理单个结果或结果列表
    ConnectivityResult singleResult;

    if (result is ConnectivityResult) {
      singleResult = result;
    } else if (result is List<ConnectivityResult> && result.isNotEmpty) {
      singleResult = result.first;
    } else {
      // 默认为无连接
      singleResult = ConnectivityResult.none;
    }

    // 更新网络类型
    _updateNetworkType(singleResult);
  }

  /// 配置Dio
  void _configureDio() {
    _dio.options
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json;

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 根据网络状况调整请求
          _adjustRequestBasedOnNetwork(options);
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // 处理网络错误
          if (_isNetworkError(error)) {
            _updateNetworkQuality(NetworkQuality.poor);
          }
          return handler.next(error);
        },
      ),
    );

    // 添加日志拦截器（仅在开发模式下）
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// 更新网络类型
  void _updateNetworkType(ConnectivityResult result) {
    final previousType = _currentNetworkType;

    switch (result) {
      case ConnectivityResult.mobile:
        _currentNetworkType = NetworkType.mobile;
        break;
      case ConnectivityResult.wifi:
        _currentNetworkType = NetworkType.wifi;
        break;
      case ConnectivityResult.ethernet:
        _currentNetworkType = NetworkType.ethernet;
        break;
      case ConnectivityResult.bluetooth:
        _currentNetworkType = NetworkType.bluetooth;
        break;
      case ConnectivityResult.vpn:
        _currentNetworkType = NetworkType.vpn;
        break;
      case ConnectivityResult.none:
        _currentNetworkType = NetworkType.none;
        break;
      default:
        _currentNetworkType = NetworkType.other;
    }

    // 如果网络类型发生变化，通知监听器
    if (previousType != _currentNetworkType) {
      _networkTypeController.add(_currentNetworkType);

      // 网络类型变化后检查网络质量
      _checkNetworkQuality();
    }
  }

  /// 检查网络质量
  Future<void> _checkNetworkQuality() async {
    if (_currentNetworkType == NetworkType.none) {
      _updateNetworkQuality(NetworkQuality.poor);
      return;
    }

    try {
      // 测量网络响应时间
      final stopwatch = Stopwatch()..start();
      await _dio.get('https://www.google.com');
      stopwatch.stop();

      final responseTime = stopwatch.elapsedMilliseconds;

      // 根据响应时间评估网络质量
      if (responseTime < 200) {
        _updateNetworkQuality(NetworkQuality.excellent);
      } else if (responseTime < 500) {
        _updateNetworkQuality(NetworkQuality.good);
      } else if (responseTime < 1000) {
        _updateNetworkQuality(NetworkQuality.moderate);
      } else {
        _updateNetworkQuality(NetworkQuality.poor);
      }
    } catch (e) {
      // 测量失败，网络质量差
      _updateNetworkQuality(NetworkQuality.poor);
    }
  }

  /// 更新网络质量
  void _updateNetworkQuality(NetworkQuality quality) {
    if (_currentNetworkQuality != quality) {
      _currentNetworkQuality = quality;
      _networkQualityController.add(quality);
    }
  }

  /// 根据网络状况调整请求
  void _adjustRequestBasedOnNetwork(RequestOptions options) {
    // 在移动网络下，可以降低图片质量
    if (_currentNetworkType == NetworkType.mobile) {
      // 如果是图片请求，添加压缩参数
      if (_isImageRequest(options.path)) {
        options.queryParameters['quality'] = 'low';
      }
    }

    // 在网络质量差的情况下，可以减少请求数据量
    if (_currentNetworkQuality == NetworkQuality.poor) {
      // 减少分页数据量
      if (options.queryParameters.containsKey('limit')) {
        final currentLimit =
            int.tryParse(options.queryParameters['limit'].toString()) ?? 20;
        options.queryParameters['limit'] = (currentLimit / 2).ceil().toString();
      }
    }
  }

  /// 判断是否为网络错误
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.error is SocketException;
  }

  /// 判断是否为图片请求
  bool _isImageRequest(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  /// 根据网络状况调整请求进行网络请求
  Future<Response> adaptiveRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final requestOptions = options ?? Options();

    // 根据网络状况设置超时
    if (_currentNetworkQuality == NetworkQuality.poor) {
      requestOptions.receiveTimeout = const Duration(seconds: 30);
      requestOptions.sendTimeout = const Duration(seconds: 30);
    } else {
      requestOptions.receiveTimeout = const Duration(seconds: 15);
      requestOptions.sendTimeout = const Duration(seconds: 15);
    }

    // 执行请求
    switch (method.toUpperCase()) {
      case 'GET':
        return _dio.get(
          url,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
      case 'POST':
        return _dio.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
      case 'PUT':
        return _dio.put(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
      case 'DELETE':
        return _dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
          cancelToken: cancelToken,
        );
      default:
        throw Exception('Unsupported method: $method');
    }
  }

  /// 批量进行网络请求
  Future<List<Response>> batchGet(
    List<String> urls, {
    Map<String, dynamic>? commonQueryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final futures = <Future<Response>>[];

    for (final url in urls) {
      futures.add(
        adaptiveRequest(
          url,
          method: 'GET',
          queryParameters: commonQueryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
      );
    }

    return Future.wait(futures);
  }

  /// 检查网络连接
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// 销毁资源
  void dispose() {
    _connectivitySubscription.cancel();
    _networkTypeController.close();
    _networkQualityController.close();
  }
}
