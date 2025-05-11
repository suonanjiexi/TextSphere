import 'package:flutter/material.dart';
import 'package:text_sphere_app/utils/offline_manager.dart';

/// 离线状态显示组件
class OfflineStatusWidget extends StatefulWidget {
  /// 是否显示同步按钮
  final bool showSyncButton;

  /// 是否显示上次同步时间
  final bool showLastSyncTime;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标尺寸
  final double iconSize;

  /// 构造函数
  const OfflineStatusWidget({
    Key? key,
    this.showSyncButton = true,
    this.showLastSyncTime = true,
    this.textStyle,
    this.iconSize = 16.0,
  }) : super(key: key);

  @override
  State<OfflineStatusWidget> createState() => _OfflineStatusWidgetState();
}

class _OfflineStatusWidgetState extends State<OfflineStatusWidget> {
  final OfflineManager _offlineManager = OfflineManager();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    // 确保离线管理器已初始化
    _ensureOfflineManagerInitialized();
  }

  @override
  void dispose() {
    // 不需要在这里调用_offlineManager.dispose()，因为它是单例模式
    // 会在应用退出时由main.dart中的代码处理
    super.dispose();
  }

  // 确保离线管理器已初始化
  Future<void> _ensureOfflineManagerInitialized() async {
    if (!_offlineManager.isInitialized) {
      try {
        await _offlineManager.init();
      } catch (e) {
        // 处理初始化错误
        debugPrint('离线管理器初始化失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _offlineManager.syncStatusStream,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data == SyncStatus.syncing || _isSyncing;
        final bool isOnline = _offlineManager.isOnline;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 网络状态图标
            Icon(
              isOnline ? Icons.cloud_done : Icons.cloud_off,
              size: widget.iconSize,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),

            // 状态文本
            Text(isOnline ? '在线' : '离线', style: widget.textStyle),

            // 显示待同步操作数量
            if (_offlineManager.getPendingOperationsCount() > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_offlineManager.getPendingOperationsCount()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.textStyle?.fontSize ?? 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            // 显示上次同步时间
            if (widget.showLastSyncTime &&
                _offlineManager.lastSyncTime != null) ...[
              const SizedBox(width: 8),
              Text(
                '上次同步: ${_offlineManager.getLastSyncTimeString()}',
                style: widget.textStyle?.copyWith(
                  fontSize: (widget.textStyle?.fontSize ?? 14) - 2,
                  color: Colors.grey,
                ),
              ),
            ],

            // 同步按钮
            if (widget.showSyncButton) ...[
              const SizedBox(width: 8),
              isSyncing
                  ? SizedBox(
                    width: widget.iconSize,
                    height: widget.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.sync),
                    iconSize: widget.iconSize,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color:
                        isOnline ? Theme.of(context).primaryColor : Colors.grey,
                    onPressed: isOnline ? _syncData : null,
                  ),
            ],
          ],
        );
      },
    );
  }

  /// 同步数据
  Future<void> _syncData() async {
    if (!_offlineManager.isOnline || _isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      await _offlineManager.syncPendingOperations();
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}
