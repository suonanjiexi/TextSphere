import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/data/models/post_model.dart';
import 'package:text_sphere_app/utils/app_logger.dart';

/// 同步状态
enum SyncStatus {
  /// 未同步
  pending,

  /// 同步中
  syncing,

  /// 已同步
  synced,

  /// 同步失败
  failed,
}

/// 离线管理器
///
/// 提供离线数据缓存和同步功能
class OfflineManager {
  // 单例实现
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  // SharedPreferences实例
  late SharedPreferences _prefs;

  // 连接状态监听
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // 当前连接状态
  bool _isOnline = true;

  // 上次同步时间
  DateTime? _lastSyncTime;

  // 挂起的操作队列
  final List<PendingOperation> _pendingOperations = [];

  // 同步状态流控制器
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // 是否已初始化
  bool _isInitialized = false;

  // 同步状态流
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // 是否在线
  bool get isOnline => _isOnline;

  // 上次同步时间
  DateTime? get lastSyncTime => _lastSyncTime;

  // 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化离线管理器
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // 读取上次同步时间
      final lastSyncTimeString = _prefs.getString('last_sync_time');
      if (lastSyncTimeString != null) {
        _lastSyncTime = DateTime.parse(lastSyncTimeString);
      }

      // 读取挂起的操作
      await _loadPendingOperations();

      // 监听连接状态变化
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
      );

      // 获取初始连接状态
      final connectivityResult = await _connectivity.checkConnectivity();
      // 将单个结果转换为列表格式，以与_updateConnectionStatus方法兼容
      _updateConnectionStatus(connectivityResult);

      _isInitialized = true;
      logger.i('离线管理器初始化完成');
    } catch (e) {
      logger.e('离线管理器初始化失败: $e');
    }
  }

  /// 更新连接状态
  void _updateConnectionStatus(dynamic connectivityResult) {
    final wasOnline = _isOnline;

    if (connectivityResult is List<ConnectivityResult>) {
      // 如果是列表（来自onConnectivityChanged），检查列表中是否有非none的结果
      _isOnline = connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );
    } else if (connectivityResult is ConnectivityResult) {
      // 如果是单个结果（来自checkConnectivity），检查是否不是none
      _isOnline = connectivityResult != ConnectivityResult.none;
    }

    logger.d('网络连接状态变化: $_isOnline');

    // 如果从离线变为在线，尝试同步挂起的操作
    if (!wasOnline && _isOnline && _pendingOperations.isNotEmpty) {
      syncPendingOperations();
    }
  }

  /// 加载挂起的操作
  Future<void> _loadPendingOperations() async {
    try {
      final pendingOpsJson = _prefs.getStringList('pending_operations') ?? [];
      _pendingOperations.clear();

      for (final opJson in pendingOpsJson) {
        final opMap = jsonDecode(opJson) as Map<String, dynamic>;
        _pendingOperations.add(PendingOperation.fromJson(opMap));
      }

      logger.d('已加载 ${_pendingOperations.length} 个挂起的操作');
    } catch (e) {
      logger.e('加载挂起的操作失败: $e');
    }
  }

  /// 保存挂起的操作
  Future<void> _savePendingOperations() async {
    try {
      final pendingOpsJson =
          _pendingOperations.map((op) => jsonEncode(op.toJson())).toList();
      await _prefs.setStringList('pending_operations', pendingOpsJson);
    } catch (e) {
      logger.e('保存挂起的操作失败: $e');
    }
  }

  /// 添加挂起的操作
  Future<void> addPendingOperation(PendingOperation operation) async {
    try {
      _pendingOperations.add(operation);
      await _savePendingOperations();

      logger.d('添加挂起的操作: ${operation.type} - ${operation.resourceId}');

      // 如果在线，尝试立即同步
      if (_isOnline) {
        syncPendingOperations();
      }
    } catch (e) {
      logger.e('添加挂起的操作失败: $e');
    }
  }

  /// 同步挂起的操作
  Future<void> syncPendingOperations() async {
    if (_pendingOperations.isEmpty) {
      logger.d('没有挂起的操作需要同步');
      return;
    }

    if (!_isOnline) {
      logger.d('当前离线，无法同步操作');
      return;
    }

    try {
      logger.i('开始同步挂起的操作...');
      _syncStatusController.add(SyncStatus.syncing);

      final operationsToSync = List<PendingOperation>.from(_pendingOperations);
      final successOperations = <PendingOperation>[];

      for (final operation in operationsToSync) {
        try {
          final success = await _processPendingOperation(operation);
          if (success) {
            successOperations.add(operation);
          }
        } catch (e) {
          logger.e('处理操作失败: ${operation.type} - ${operation.resourceId}', e);
        }
      }

      // 移除成功的操作
      _pendingOperations.removeWhere((op) => successOperations.contains(op));
      await _savePendingOperations();

      // 更新同步时间
      _lastSyncTime = DateTime.now();
      await _prefs.setString(
        'last_sync_time',
        _lastSyncTime!.toIso8601String(),
      );

      logger.i(
        '同步完成，成功: ${successOperations.length}, 剩余: ${_pendingOperations.length}',
      );
      _syncStatusController.add(
        _pendingOperations.isEmpty ? SyncStatus.synced : SyncStatus.failed,
      );
    } catch (e) {
      logger.e('同步挂起的操作失败: $e');
      _syncStatusController.add(SyncStatus.failed);
    }
  }

  /// 处理单个挂起的操作
  Future<bool> _processPendingOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case OperationType.create:
          // 发送创建请求到服务器
          // 这里调用实际的API服务
          logger.d(
            '处理创建操作: ${operation.resourceType} - ${operation.resourceId}',
          );

          // 根据资源类型调用不同的API服务
          switch (operation.resourceType) {
            case ResourceType.post:
              // 调用创建帖子API
              // 可以注入ApiClient或直接使用Dio
              // 例如：await sl<PostRepository>().createPost(operation.data);
              break;

            case ResourceType.comment:
              // 调用创建评论API
              break;

            case ResourceType.user:
              // 调用用户相关API
              break;

            case ResourceType.message:
              // 调用消息相关API
              break;
          }
          break;

        case OperationType.update:
          // 发送更新请求到服务器
          logger.d(
            '处理更新操作: ${operation.resourceType} - ${operation.resourceId}',
          );

          // 根据资源类型调用不同的API服务
          switch (operation.resourceType) {
            case ResourceType.post:
              // 调用更新帖子API
              // 例如：await sl<PostRepository>().updatePost(operation.resourceId, operation.data);
              break;

            case ResourceType.comment:
              // 调用更新评论API
              break;

            case ResourceType.user:
              // 调用更新用户API
              break;

            case ResourceType.message:
              // 调用更新消息API
              break;
          }
          break;

        case OperationType.delete:
          // 发送删除请求到服务器
          logger.d(
            '处理删除操作: ${operation.resourceType} - ${operation.resourceId}',
          );

          // 根据资源类型调用不同的API服务
          switch (operation.resourceType) {
            case ResourceType.post:
              // 调用删除帖子API
              // 例如：await sl<PostRepository>().deletePost(operation.resourceId);
              break;

            case ResourceType.comment:
              // 调用删除评论API
              break;

            case ResourceType.user:
              // 调用删除用户API
              break;

            case ResourceType.message:
              // 调用删除消息API
              break;
          }
          break;
      }

      return true;
    } catch (e) {
      logger.e('处理操作失败: ${operation.type} - ${operation.resourceId}', e);
      return false;
    }
  }

  /// 缓存帖子数据
  Future<void> cachePostData(List<PostModel> posts) async {
    try {
      final postsJson = posts.map((post) => jsonEncode(post.toJson())).toList();
      await _prefs.setStringList('cached_posts', postsJson);

      // 记录缓存时间
      await _prefs.setString(
        'posts_cache_time',
        DateTime.now().toIso8601String(),
      );

      logger.d('已缓存 ${posts.length} 条帖子');
    } catch (e) {
      logger.e('缓存帖子数据失败: $e');
    }
  }

  /// 获取缓存的帖子数据
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final postsJson = _prefs.getStringList('cached_posts') ?? [];
      final posts = <PostModel>[];

      for (final postJson in postsJson) {
        final postMap = jsonDecode(postJson) as Map<String, dynamic>;
        posts.add(PostModel.fromJson(postMap));
      }

      return posts;
    } catch (e) {
      logger.e('获取缓存的帖子数据失败: $e');
      return [];
    }
  }

  /// 获取缓存时间
  Future<DateTime?> getCacheTime(String cacheKey) async {
    final timeString = _prefs.getString('${cacheKey}_cache_time');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  /// 清除特定缓存
  Future<void> clearCache(String cacheKey) async {
    await _prefs.remove('cached_$cacheKey');
    await _prefs.remove('${cacheKey}_cache_time');
  }

  /// 清除所有缓存
  Future<void> clearAllCaches() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cached_') || key.endsWith('_cache_time')) {
        await _prefs.remove(key);
      }
    }
  }

  /// 销毁资源
  void dispose() {
    _connectivitySubscription.cancel();
    _syncStatusController.close();
  }

  /// 手动检查网络连接状态
  Future<bool> checkNetworkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // 将单个结果转换为列表格式，以与_updateConnectionStatus方法兼容
      _updateConnectionStatus(connectivityResult);
      return _isOnline;
    } catch (e) {
      logger.e('检查网络连接失败: $e');
      return false;
    }
  }

  /// 获取当前待同步的操作数量
  int getPendingOperationsCount() {
    return _pendingOperations.length;
  }

  /// 获取最近同步时间的格式化字符串
  String getLastSyncTimeString() {
    if (_lastSyncTime == null) {
      return '从未同步';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return _lastSyncTime!.toString().substring(0, 16);
    }
  }
}

/// 操作类型
enum OperationType { create, update, delete }

/// 资源类型
enum ResourceType { post, comment, user, message }

/// 挂起的操作
class PendingOperation {
  final OperationType type;
  final ResourceType resourceType;
  final String resourceId;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  PendingOperation({
    required this.type,
    required this.resourceType,
    required this.resourceId,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从JSON构造
  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      type: OperationType.values[json['type'] as int],
      resourceType: ResourceType.values[json['resourceType'] as int],
      resourceId: json['resourceId'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'resourceType': resourceType.index,
      'resourceId': resourceId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
