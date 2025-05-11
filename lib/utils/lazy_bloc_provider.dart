import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC创建器函数类型定义
typedef BlocCreator<T extends Bloc> = T Function(BuildContext context);

/// 懒加载BLoC提供者
/// 仅在需要时创建BLoC实例，优化内存和性能
class LazyBlocProvider<T extends Bloc> extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// BLoC创建函数
  final BlocCreator<T> create;

  /// 是否延迟创建BLoC
  /// 当设置为true时，仅在首次访问时才会创建BLoC
  final bool lazy;

  /// 构造函数
  const LazyBlocProvider({
    Key? key,
    required this.child,
    required this.create,
    this.lazy = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(create: create, lazy: lazy, child: child);
  }
}

/// 多个懒加载BLoC提供者
/// 同时提供多个BLoC实例
class LazyMultiBlocProvider extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// BLoC提供者列表
  final List<Widget> providers;

  /// 构造函数
  const LazyMultiBlocProvider({
    Key? key,
    required this.providers,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 构建嵌套的BlocProvider结构
    Widget result = child;

    // 从内向外嵌套提供者
    for (int i = providers.length - 1; i >= 0; i--) {
      result = providers[i] is BlocProvider ? providers[i] : result;
    }

    return result;
  }
}

/// 懒加载BLoC消费者
/// 结合了BlocListener和BlocBuilder功能
class LazyBlocConsumer<B extends Bloc<E, S>, E, S> extends StatelessWidget {
  /// 构建界面的函数
  final BlocWidgetBuilder<S> builder;

  /// 监听BLoC状态变化的函数
  final BlocWidgetListener<S> listener;

  /// 监听的条件
  final BlocListenerCondition<S>? listenWhen;

  /// 构建的条件
  final BlocBuilderCondition<S>? buildWhen;

  /// 构造函数
  const LazyBlocConsumer({
    Key? key,
    required this.builder,
    required this.listener,
    this.listenWhen,
    this.buildWhen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      listener: listener,
      builder: builder,
      listenWhen: listenWhen,
      buildWhen: buildWhen,
    );
  }
}

/// 按需BLoC提供者
/// 仅在特定条件下创建和提供BLoC
class ConditionalBlocProvider<T extends Bloc> extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// BLoC创建函数
  final BlocCreator<T> create;

  /// 条件函数，决定是否创建和提供BLoC
  final bool Function(BuildContext) condition;

  /// 构造函数
  const ConditionalBlocProvider({
    Key? key,
    required this.child,
    required this.create,
    required this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return condition(context)
        ? BlocProvider<T>(create: create, child: child)
        : child;
  }
}

/// BLoC提供者扩展
extension LazyBlocProviderExtensions on BuildContext {
  /// 懒加载方式获取BLoC
  /// 提供额外的延迟加载控制
  T readBloc<T extends Bloc>() {
    return BlocProvider.of<T>(this, listen: false);
  }

  /// 监听并获取BLoC
  T watchBloc<T extends Bloc>() {
    return BlocProvider.of<T>(this, listen: true);
  }

  /// 安全地获取BLoC，如果不存在则返回null
  T? maybeBloc<T extends Bloc>() {
    try {
      return BlocProvider.of<T>(this, listen: false);
    } catch (e) {
      return null;
    }
  }
}
