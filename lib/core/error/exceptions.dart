/// 服务器异常
class ServerException implements Exception {}

/// 缓存异常
class CacheException implements Exception {}

/// 网络异常
class NetworkException implements Exception {}

/// 认证异常
class AuthenticationException implements Exception {}

/// 请求异常
class RequestException implements Exception {
  final String message;
  RequestException(this.message);
}
