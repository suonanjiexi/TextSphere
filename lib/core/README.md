# 核心模块 (Core)

## 概述

核心模块包含应用程序的基础架构组件，这些组件与具体业务逻辑无关，但为整个应用提供基础支持。包括网络通信、依赖注入、错误处理、路由管理等基础功能。

## 模块结构

- **auth/**: 认证相关的核心组件
- **cache/**: 缓存管理和策略
- **di/**: 依赖注入容器和配置
- **error/**: 错误类型定义和处理策略
- **network/**: 网络请求和连接管理
- **router/**: 应用路由配置和管理
- **routes/**: 路由相关常量和助手方法
- **theme/**: 主题定义和管理

## 依赖注入 (DI)

应用使用`get_it`库实现依赖注入。依赖注入系统支持多环境配置，包括开发环境、测试环境和生产环境。

### 使用示例

```dart
// 注册服务
sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

// 获取服务
final networkInfo = sl<NetworkInfo>();
```

### 环境配置

依赖注入系统支持多环境配置：

```dart
// 初始化依赖，指定环境
await di.init(environment: Environment.production);

// 根据环境注册不同实现
final apiClient = registerForEnvironment<ApiClient>(
  devFactory: () => DevApiClient(),
  testFactory: () => MockApiClient(),
  prodFactory: () => ProdApiClient(),
);
```

## 错误处理

应用采用统一的错误处理策略，使用Either类型返回结果或错误。所有可能的错误都在`core/error/failures.dart`中定义。

### 错误类型

- **ServerFailure**: 服务器错误
- **CacheFailure**: 缓存错误
- **NetworkFailure**: 网络连接错误
- **AuthFailure**: 认证错误
- **ValidationFailure**: 输入验证错误
- **PermissionFailure**: 权限不足错误
- **NotFoundFailure**: 资源不存在错误

### 使用示例

```dart
// 使用Either返回结果或错误
Future<Either<Failure, User>> login(String username, String password) async {
  try {
    final user = await _remoteDataSource.login(username, password);
    return Right(user);
  } on ServerException {
    return Left(ServerFailure(message: '服务器错误'));
  } on NetworkException {
    return Left(NetworkFailure(message: '网络连接错误'));
  }
}

// 使用错误处理包装器
final result = await AppExceptionHandler.runEither(
  () => userRepository.login(username, password),
  context: context,
  operationName: '登录',
);
```

## 网络

应用使用Dio库处理网络请求，并实现了灵活的请求拦截器和错误处理机制。

### 使用示例

```dart
// 创建请求
final response = await apiClient.get('/users', queryParameters: {'page': 1});

// 处理网络质量变化的自适应请求
final response = await networkManager.adaptiveRequest(
  '/users',
  method: 'GET',
  queryParameters: {'page': 1},
);
```

## 路由

应用使用go_router管理路由，所有路由定义在`core/router/app_router.dart`中。

### 使用示例

```dart
// 导航到新页面
context.go('/home/square/detail/$postId');

// 带参数导航
context.goNamed(
  'user_profile',
  pathParameters: {'userId': userId},
  queryParameters: {'tab': 'posts'},
);
```

## 主题

应用支持动态切换主题，包括明亮模式和深色模式。主题定义在`core/theme/app_theme.dart`中。

### 使用示例

```dart
// 获取当前主题
final theme = context.watch<ThemeBloc>().state.themeData;

// 切换主题
context.read<ThemeBloc>().add(ToggleTheme());
``` 