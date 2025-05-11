/// 对象工厂函数类型定义
typedef ObjectFactory<T> = T Function();

/// 对象重置函数类型定义
typedef ObjectReset<T> = void Function(T object);

/// 对象池管理类
/// 复用常用对象，减少GC压力
class ObjectPool<T> {
  /// 池中的对象列表
  final List<T> _pool = [];

  /// 对象工厂函数，用于创建新对象
  final ObjectFactory<T> _factory;

  /// 对象重置函数，用于重置对象状态
  final ObjectReset<T>? _reset;

  /// 池的最大容量
  final int _maxPoolSize;

  /// 创建对象池
  ///
  /// [factory] 创建新对象的工厂函数
  /// [reset] 重置对象状态的函数（可选）
  /// [initialSize] 初始池大小
  /// [maxPoolSize] 池的最大容量
  ObjectPool({
    required ObjectFactory<T> factory,
    ObjectReset<T>? reset,
    int initialSize = 0,
    int maxPoolSize = 100,
  }) : _factory = factory,
       _reset = reset,
       _maxPoolSize = maxPoolSize {
    // 预创建初始对象
    for (int i = 0; i < initialSize; i++) {
      _pool.add(_factory());
    }
  }

  /// 从池中获取对象
  /// 如果池为空，则创建新对象
  T acquire() {
    if (_pool.isEmpty) {
      return _factory();
    }
    return _pool.removeLast();
  }

  /// 归还对象到池中
  ///
  /// [object] 要归还的对象
  void release(T object) {
    // 如果池已满，则不添加
    if (_pool.length >= _maxPoolSize) {
      return;
    }

    // 如果提供了重置函数，则重置对象状态
    if (_reset != null) {
      _reset!(object);
    }

    _pool.add(object);
  }

  /// 清空池中的所有对象
  void clear() {
    _pool.clear();
  }

  /// 预热池，创建指定数量的对象
  void warm(int count) {
    // 计算需要创建的对象数量
    final toCreate = count - _pool.length;
    if (toCreate <= 0) return;

    // 创建新对象并添加到池中
    for (int i = 0; i < toCreate; i++) {
      if (_pool.length >= _maxPoolSize) break;
      _pool.add(_factory());
    }
  }

  /// 获取池中当前的对象数量
  int get size => _pool.length;

  /// 获取池的最大容量
  int get maxSize => _maxPoolSize;

  /// 使用对象池执行函数
  /// 自动管理对象的获取和释放
  R use<R>(R Function(T object) action) {
    final object = acquire();
    try {
      return action(object);
    } finally {
      release(object);
    }
  }
}
