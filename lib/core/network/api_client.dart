import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error/failures.dart';

/// API客户端
///
/// 处理与后端API的通信
class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;

  /// API基础URL
  final String baseUrl;

  /// 构造函数
  ApiClient(this._dio, this._prefs)
    : baseUrl = dotenv.get(
        'API_BASE_URL',
        fallback: 'http://localhost:8080/api',
      );

  /// 初始化API客户端
  void init() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 添加拦截器来处理请求和响应
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加认证令牌（如果有）
          final token = _prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 处理成功的响应
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // 处理错误的响应
          return handler.next(e);
        },
      ),
    );
  }

  /// 发送GET请求
  ///
  /// 参数:
  /// - [path]: API路径
  /// - [queryParameters]: 查询参数
  ///
  /// 返回:
  /// - API响应数据
  ///
  /// 抛出:
  /// - [ServerFailure]: 服务器错误
  /// - [NetworkFailure]: 网络错误
  /// - [AuthFailure]: 认证错误
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送POST请求
  ///
  /// 参数:
  /// - [path]: API路径
  /// - [data]: 请求数据
  /// - [queryParameters]: 查询参数
  ///
  /// 返回:
  /// - API响应数据
  ///
  /// 抛出:
  /// - [ServerFailure]: 服务器错误
  /// - [NetworkFailure]: 网络错误
  /// - [AuthFailure]: 认证错误
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送PUT请求
  ///
  /// 参数:
  /// - [path]: API路径
  /// - [data]: 请求数据
  /// - [queryParameters]: 查询参数
  ///
  /// 返回:
  /// - API响应数据
  ///
  /// 抛出:
  /// - [ServerFailure]: 服务器错误
  /// - [NetworkFailure]: 网络错误
  /// - [AuthFailure]: 认证错误
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送DELETE请求
  ///
  /// 参数:
  /// - [path]: API路径
  /// - [queryParameters]: 查询参数
  ///
  /// 返回:
  /// - API响应数据
  ///
  /// 抛出:
  /// - [ServerFailure]: 服务器错误
  /// - [NetworkFailure]: 网络错误
  /// - [AuthFailure]: 认证错误
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  ///
  /// 参数:
  /// - [path]: API路径
  /// - [filePath]: 本地文件路径
  /// - [fileFieldName]: 文件字段名
  /// - [data]: 附加数据
  ///
  /// 返回:
  /// - API响应数据
  ///
  /// 抛出:
  /// - [ServerFailure]: 服务器错误
  /// - [NetworkFailure]: 网络错误
  /// - [AuthFailure]: 认证错误
  Future<dynamic> uploadFile(
    String path,
    String filePath, {
    String fileFieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileFieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(path, data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 处理API响应
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw ServerFailure(message: response.data['message'] ?? '服务器错误');
    }
  }

  /// 处理API错误
  Failure _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(message: '连接超时');
      case DioExceptionType.badCertificate:
        return NetworkFailure(message: '证书验证失败');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return AuthFailure(message: '认证失败');
        } else if (statusCode == 403) {
          return PermissionFailure(message: '权限不足');
        } else if (statusCode == 404) {
          return NotFoundFailure(message: '资源不存在');
        } else if (statusCode == 422) {
          final errors = e.response?.data['errors'];
          return ValidationFailure(
            message: e.response?.data['message'] ?? '输入验证失败',
            errors:
                errors is Map<String, dynamic>
                    ? Map<String, String>.from(errors)
                    : {},
          );
        }
        return ServerFailure(message: e.response?.data['message'] ?? '服务器错误');
      case DioExceptionType.cancel:
        return NetworkFailure(message: '请求被取消');
      case DioExceptionType.connectionError:
        return NetworkFailure(message: '连接错误');
      case DioExceptionType.unknown:
      default:
        return NetworkFailure(message: '网络错误: ${e.message}');
    }
  }
}
