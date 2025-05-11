import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget生命周期管理Mixin
/// 优化资源管理和事件处理
mixin WidgetLifecycleMixin<T extends StatefulWidget> on State<T> {
  /// 当前Widget是否可见
  bool _isVisible = false;

  /// 当前Widget是否在前台
  bool _isActive = false;

  /// 当前Widget是否处于暂停状态
  bool _isPaused = false;

  /// 检查Widget是否可见
  bool get isVisible => _isVisible;

  /// 检查Widget是否活跃（在前台）
  bool get isActive => _isActive;

  /// 检查Widget是否暂停
  bool get isPaused => _isPaused;

  /// Widget挂载时间
  DateTime? _mountedTime;

  /// 可见时间总计（毫秒）
  int _visibleDuration = 0;

  /// 上次可见时间点
  DateTime? _lastVisibleTime;

  @override
  void initState() {
    super.initState();

    // 记录挂载时间
    _mountedTime = DateTime.now();

    // 延迟检查可见性状态以确保布局完成
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkVisibility();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当Widget更新时可能影响可见性
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void dispose() {
    // 如果Widget处于可见状态，更新可见时间
    if (_isVisible && _lastVisibleTime != null) {
      final now = DateTime.now();
      _visibleDuration += now.difference(_lastVisibleTime!).inMilliseconds;
    }

    // 调用子类自定义的释放逻辑
    onDispose();

    // 调用原始dispose
    super.dispose();
  }

  /// 检查Widget是否可见
  void _checkVisibility() {
    // 确保上下文有效
    if (!mounted) return;

    final bool wasVisible = _isVisible;
    final bool wasPaused = _isPaused;
    final bool wasActive = _isActive;

    // 检查Widget是否在视图中
    _updateVisibilityState();

    // 状态变化回调
    if (wasVisible != _isVisible) {
      if (_isVisible) {
        _lastVisibleTime = DateTime.now();
        onBecameVisible();
      } else {
        if (_lastVisibleTime != null) {
          final now = DateTime.now();
          _visibleDuration += now.difference(_lastVisibleTime!).inMilliseconds;
        }
        onBecameInvisible();
      }
    }

    if (wasPaused != _isPaused) {
      if (_isPaused) {
        onPaused();
      } else {
        onResumed();
      }
    }

    if (wasActive != _isActive) {
      if (_isActive) {
        onActivated();
      } else {
        onDeactivated();
      }
    }
  }

  /// 更新可见性状态
  void _updateVisibilityState() {
    // 检查Widget是否在视图树中并可见
    final RenderObject? renderObject = context.findRenderObject();

    if (renderObject == null || !renderObject.attached) {
      _isVisible = false;
      return;
    }

    // 如果是RenderBox，检查是否在视口内
    if (renderObject is RenderBox) {
      // 获取Widget在全局中的位置
      final RenderBox box = renderObject;

      // 检查是否在视口内
      if (!box.hasSize || box.size.isEmpty) {
        _isVisible = false;
        return;
      }

      // 获取应用窗口大小
      final Size window = MediaQuery.of(context).size;

      try {
        // 获取Widget的全局坐标
        final Offset globalPosition = box.localToGlobal(Offset.zero);

        // 判断Widget是否在屏幕内
        final bool isOnScreen =
            !(globalPosition.dy + box.size.height < 0 || // 完全在屏幕上方
                globalPosition.dy > window.height || // 完全在屏幕下方
                globalPosition.dx + box.size.width < 0 || // 完全在屏幕左侧
                globalPosition.dx >
                    window
                        .width // 完全在屏幕右侧
                        );

        // 更新可见性状态
        _isVisible = isOnScreen;
      } catch (e) {
        // 如果无法确定位置，默认为不可见
        _isVisible = false;
      }
    } else {
      // 如果不是RenderBox，则简单地检查是否附加到渲染树
      _isVisible = renderObject.attached;
    }

    // 检查应用程序是否活跃
    _isActive =
        SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed;

    // 检查是否暂停
    _isPaused = !_isActive || ModalRoute.of(context)?.isCurrent == false;
  }

  /// 获取Widget可见时间（毫秒）
  int getVisibleDuration() {
    if (_isVisible && _lastVisibleTime != null) {
      final now = DateTime.now();
      return _visibleDuration +
          now.difference(_lastVisibleTime!).inMilliseconds;
    }
    return _visibleDuration;
  }

  /// 获取Widget挂载时间（毫秒）
  int getMountedDuration() {
    if (_mountedTime != null) {
      final now = DateTime.now();
      return now.difference(_mountedTime!).inMilliseconds;
    }
    return 0;
  }

  /// 请求立即检查可见性状态
  void checkVisibility() {
    _checkVisibility();
  }

  // 以下方法可以在子类中重写以添加自定义行为

  /// 当Widget变为可见时调用
  void onBecameVisible() {}

  /// 当Widget变为不可见时调用
  void onBecameInvisible() {}

  /// 当Widget暂停时调用
  void onPaused() {}

  /// 当Widget恢复时调用
  void onResumed() {}

  /// 当Widget激活时调用
  void onActivated() {}

  /// 当Widget停用时调用
  void onDeactivated() {}

  /// 当Widget销毁时调用
  void onDispose() {}
}
