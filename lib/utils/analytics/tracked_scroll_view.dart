import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'user_action_tracker.dart';

/// 跟踪滚动视图组件
///
/// 用于跟踪用户滚动列表的行为
class TrackedListView extends StatefulWidget {
  final String listName;
  final String? screenName;
  final List<Widget> children;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  /// 创建一个被跟踪的列表视图
  const TrackedListView({
    Key? key,
    required this.listName,
    this.screenName,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.itemCount,
  }) : super(key: key);

  @override
  State<TrackedListView> createState() => _TrackedListViewState();
}

class _TrackedListViewState extends State<TrackedListView> {
  final UserActionTracker _tracker = UserActionTracker();
  late ScrollController _scrollController;
  bool _isScrolling = false;
  int _lastTrackedIndex = 0;
  final int _trackingInterval = 10; // 每滚动10个项目记录一次

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      _tracker.trackCustomEvent(
        'scroll_start',
        '用户开始滚动：${widget.listName}',
        properties: {
          'list_name': widget.listName,
          'screen_name': widget.screenName,
          'position': _scrollController.position.pixels,
        },
      );
    }

    // 获取当前可见项的索引
    if (widget.itemBuilder != null && widget.itemCount != null) {
      final int currentIndex =
          (_scrollController.position.pixels /
                  (_scrollController.position.maxScrollExtent /
                      widget.itemCount!))
              .floor();

      // 如果滚动了足够的距离，记录一次
      if ((currentIndex - _lastTrackedIndex).abs() >= _trackingInterval) {
        _lastTrackedIndex = currentIndex;
        _tracker.trackCustomEvent(
          'scroll_position',
          '用户滚动到列表位置：${widget.listName} - 索引 $currentIndex',
          properties: {
            'list_name': widget.listName,
            'screen_name': widget.screenName,
            'index': currentIndex,
            'position': _scrollController.position.pixels,
            'max_position': _scrollController.position.maxScrollExtent,
          },
        );
      }
    }

    // 防抖检测滚动结束
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isScrolling) {
        _isScrolling = false;
        _tracker.trackCustomEvent(
          'scroll_end',
          '用户结束滚动：${widget.listName}',
          properties: {
            'list_name': widget.listName,
            'screen_name': widget.screenName,
            'position': _scrollController.position.pixels,
            'max_position': _scrollController.position.maxScrollExtent,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemBuilder != null) {
      return ListView.builder(
        key: widget.key,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemBuilder: widget.itemBuilder!,
        itemCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    } else {
      return ListView(
        key: widget.key,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        children: widget.children,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    }
  }
}

/// 跟踪的GridView
class TrackedGridView extends StatefulWidget {
  final String gridName;
  final String? screenName;
  final List<Widget> children;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  /// 创建一个被跟踪的网格视图
  const TrackedGridView({
    Key? key,
    required this.gridName,
    this.screenName,
    required this.gridDelegate,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.itemCount,
  }) : super(key: key);

  @override
  State<TrackedGridView> createState() => _TrackedGridViewState();
}

class _TrackedGridViewState extends State<TrackedGridView> {
  final UserActionTracker _tracker = UserActionTracker();
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      _tracker.trackCustomEvent(
        'grid_scroll_start',
        '用户开始滚动网格：${widget.gridName}',
        properties: {
          'grid_name': widget.gridName,
          'screen_name': widget.screenName,
          'position': _scrollController.position.pixels,
        },
      );
    }

    // 防抖检测滚动结束
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isScrolling) {
        _isScrolling = false;
        _tracker.trackCustomEvent(
          'grid_scroll_end',
          '用户结束滚动网格：${widget.gridName}',
          properties: {
            'grid_name': widget.gridName,
            'screen_name': widget.screenName,
            'position': _scrollController.position.pixels,
            'max_position': _scrollController.position.maxScrollExtent,
            'scroll_percentage':
                (_scrollController.position.pixels /
                        _scrollController.position.maxScrollExtent *
                        100)
                    .toStringAsFixed(1) +
                '%',
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemBuilder != null) {
      return GridView.builder(
        key: widget.key,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        gridDelegate: widget.gridDelegate,
        itemBuilder: widget.itemBuilder!,
        itemCount: widget.itemCount,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    } else {
      return GridView.count(
        key: widget.key,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        crossAxisCount:
            (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .crossAxisCount,
        mainAxisSpacing:
            (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .mainAxisSpacing,
        crossAxisSpacing:
            (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .crossAxisSpacing,
        childAspectRatio:
            (widget.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
                .childAspectRatio,
        children: widget.children,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    }
  }
}
