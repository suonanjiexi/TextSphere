import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../app_logger.dart';

/// 用户行为跟踪器
///
/// 用于记录用户的操作行为并将其打印到控制台
/// 包括页面访问、按钮点击以及收集设备和网络信息
class UserActionTracker {
  /// 单例实例
  static final UserActionTracker _instance = UserActionTracker._internal();

  /// 设备信息
  DeviceInfo? _deviceInfo;

  /// 应用信息
  PackageInfo? _packageInfo;

  /// 是否初始化完成
  bool _initialized = false;

  /// 工厂构造函数
  factory UserActionTracker() {
    return _instance;
  }

  /// 私有构造函数
  UserActionTracker._internal();

  /// 初始化跟踪器
  Future<void> init() async {
    if (_initialized) return;

    try {
      // 收集设备信息
      await _collectDeviceInfo();

      // 收集应用信息
      _packageInfo = await PackageInfo.fromPlatform();

      _initialized = true;

      // 记录启动事件
      trackAppOpen();

      logger.i('用户行为跟踪器初始化成功');
    } catch (e, stack) {
      logger.e('用户行为跟踪器初始化失败', e, stack);
    }
  }

  /// 收集设备信息
  Future<void> _collectDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo = DeviceInfo(
          platform: 'Android',
          model: androidInfo.model,
          osVersion: androidInfo.version.release,
          deviceId: androidInfo.id,
          brand: androidInfo.brand,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = DeviceInfo(
          platform: 'iOS',
          model: iosInfo.model ?? 'Unknown',
          osVersion: iosInfo.systemVersion ?? 'Unknown',
          deviceId: iosInfo.identifierForVendor ?? 'Unknown',
          brand: 'Apple',
        );
      } else {
        _deviceInfo = DeviceInfo(
          platform: 'Web/Other',
          model: 'Unknown',
          osVersion: 'Unknown',
          deviceId: 'Unknown',
          brand: 'Unknown',
        );
      }
    } catch (e) {
      logger.w('收集设备信息失败: $e');
      _deviceInfo = DeviceInfo(
        platform: 'Unknown',
        model: 'Unknown',
        osVersion: 'Unknown',
        deviceId: 'Unknown',
        brand: 'Unknown',
      );
    }
  }

  /// 获取当前网络状态
  Future<String> _getNetworkStatus() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      switch (connectivity) {
        case ConnectivityResult.wifi:
          return '无线网络 (WiFi)';
        case ConnectivityResult.mobile:
          return '移动数据网络';
        case ConnectivityResult.ethernet:
          return '以太网';
        case ConnectivityResult.bluetooth:
          return '蓝牙';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.none:
          return '无网络连接';
        default:
          return '未知';
      }
    } catch (e) {
      logger.w('获取网络状态失败: $e');
      return '未知';
    }
  }

  /// 记录页面访问行为
  void trackPageView(String pageName, {Map<String, dynamic>? properties}) {
    _trackAction('page_view', '用户访问了页面：$pageName', {
      'page_name': pageName,
      ...?properties,
    });
  }

  /// 记录按钮点击行为
  void trackButtonClick(
    String buttonName, {
    String? screenName,
    Map<String, dynamic>? properties,
  }) {
    _trackAction(
      'button_click',
      '用户点击了按钮：$buttonName${screenName != null ? ' (在 $screenName 页面)' : ''}',
      {'button_name': buttonName, 'screen_name': screenName, ...?properties},
    );
  }

  /// 记录列表项点击行为
  void trackListItemClick(
    String listName,
    String itemId, {
    String? screenName,
    Map<String, dynamic>? properties,
  }) {
    _trackAction(
      'list_item_click',
      '用户点击了列表项：$listName - ID: $itemId${screenName != null ? ' (在 $screenName 页面)' : ''}',
      {
        'list_name': listName,
        'item_id': itemId,
        'screen_name': screenName,
        ...?properties,
      },
    );
  }

  /// 记录搜索行为
  void trackSearch(
    String searchTerm, {
    String? screenName,
    Map<String, dynamic>? properties,
  }) {
    _trackAction(
      'search',
      '用户搜索了：$searchTerm${screenName != null ? ' (在 $screenName 页面)' : ''}',
      {'search_term': searchTerm, 'screen_name': screenName, ...?properties},
    );
  }

  /// 记录应用启动行为
  void trackAppOpen() {
    _trackAction('app_open', '用户启动了应用', {
      'app_version': _packageInfo?.version ?? 'Unknown',
      'build_number': _packageInfo?.buildNumber ?? 'Unknown',
    });
  }

  /// 记录应用关闭行为
  void trackAppClose() {
    _trackAction('app_close', '用户关闭了应用', {});
  }

  /// 记录错误行为
  void trackError(
    String errorType,
    String errorMessage, {
    StackTrace? stackTrace,
    Map<String, dynamic>? properties,
  }) {
    _trackAction('error', '发生错误：$errorType - $errorMessage', {
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace?.toString(),
      ...?properties,
    });
  }

  /// 记录自定义行为
  void trackCustomEvent(
    String eventName,
    String description, {
    Map<String, dynamic>? properties,
  }) {
    _trackAction(eventName, description, properties ?? {});
  }

  /// 内部跟踪行为的方法
  Future<void> _trackAction(
    String actionType,
    String description,
    Map<String, dynamic> properties,
  ) async {
    if (!_initialized) {
      // 如果没有初始化完成，先初始化
      await init();
    }

    final networkStatus = await _getNetworkStatus();
    final timestamp = DateTime.now();

    // 构建用户行为对象
    final userAction = UserAction(
      type: actionType,
      description: description,
      timestamp: timestamp,
      deviceInfo:
          _deviceInfo ??
          DeviceInfo(
            platform: 'Unknown',
            model: 'Unknown',
            osVersion: 'Unknown',
            deviceId: 'Unknown',
            brand: 'Unknown',
          ),
      networkType: networkStatus,
      properties: properties,
    );

    // 打印到控制台
    _printActionToConsole(userAction);

    // 这里可以添加将行为发送到服务器的逻辑
  }

  /// 打印行为到控制台
  void _printActionToConsole(UserAction action) {
    // 构建格式化的字符串
    final sb = StringBuffer();
    sb.writeln('----------- 用户行为跟踪 -----------');
    sb.writeln('时间: ${_formatDateTime(action.timestamp)}');
    sb.writeln('类型: ${action.type}');
    sb.writeln('描述: ${action.description}');
    sb.writeln(
      '设备: ${action.deviceInfo.brand} ${action.deviceInfo.model} - ${action.deviceInfo.platform} ${action.deviceInfo.osVersion}',
    );
    sb.writeln('网络: ${action.networkType}');

    if (action.properties.isNotEmpty) {
      sb.writeln('附加属性:');
      action.properties.forEach((key, value) {
        if (value != null) {
          sb.writeln('  $key: $value');
        }
      });
    }

    sb.writeln('-----------------------------------');

    // 打印到控制台
    logger.i(sb.toString());
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} '
        '${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}:${_padZero(dateTime.second)}';
  }

  /// 补零函数
  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}

/// 设备信息数据类
class DeviceInfo {
  final String platform;
  final String model;
  final String osVersion;
  final String deviceId;
  final String brand;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.osVersion,
    required this.deviceId,
    required this.brand,
  });

  @override
  String toString() {
    return '$brand $model ($platform $osVersion)';
  }
}

/// 用户行为数据类
class UserAction {
  final String type;
  final String description;
  final DateTime timestamp;
  final DeviceInfo deviceInfo;
  final String networkType;
  final Map<String, dynamic> properties;

  UserAction({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.deviceInfo,
    required this.networkType,
    required this.properties,
  });
}
