/// 网络信息接口
abstract class NetworkInfo {
  /// 判断设备是否联网
  Future<bool> get isConnected;
}

/// 模拟网络信息实现，总是返回已连接
class MockNetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
