import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/user/login_usecase.dart';
import '../../domain/usecases/user/register_usecase.dart';
import '../../domain/usecases/user/get_current_user_usecase.dart';
// import '../../domain/usecases/user/logout_usecase.dart';
import '../../domain/usecases/message/get_conversations_usecase.dart';
import '../../domain/usecases/message/get_messages_usecase.dart';
import '../../domain/usecases/message/send_message_usecase.dart';
import '../../domain/usecases/post/get_posts_usecase.dart';
// import '../../domain/usecases/circle/get_joined_circles_usecase.dart';
// import '../../domain/usecases/circle/get_recommended_circles_usecase.dart';
// import '../../domain/usecases/circle/search_circles_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/comment.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../presentation/blocs/post_detail/post_detail_bloc.dart';
import '../../presentation/blocs/post_detail/post_detail_event.dart';
import '../../presentation/blocs/square/square_bloc.dart';
import '../../presentation/blocs/square/square_search_bloc.dart';
import '../../presentation/blocs/circle/circle_bloc.dart';
import '../../domain/repositories/circle_repository.dart';
import '../../data/repositories/circle_repository_impl.dart';
import '../../data/datasources/circle/circle_remote_data_source.dart';
import '../../data/datasources/circle/circle_local_data_source.dart';
import '../../presentation/blocs/user_search/user_search_bloc.dart';
import '../../presentation/blocs/chat/chat_bloc.dart';
import '../../utils/app_logger.dart';
import '../../utils/network_monitor.dart';
// import '../../domain/repositories/auth_repository.dart';
// import '../../data/repositories/auth_repository_impl.dart';
// import '../../data/datasources/auth/auth_local_data_source.dart';
// import '../../data/datasources/auth/auth_remote_data_source.dart';
// import '../../domain/repositories/theme_repository.dart';
// import '../../data/repositories/theme_repository_impl.dart';
// import '../../domain/repositories/search_repository.dart';
// import '../../data/repositories/search_repository_impl.dart';

final GetIt sl = GetIt.instance;

// 添加环境配置枚举
enum Environment { development, testing, production }

// 当前环境
Environment _currentEnvironment = Environment.development;

// 获取当前环境
Environment get currentEnvironment => _currentEnvironment;

// 设置当前环境
void setEnvironment(Environment environment) {
  _currentEnvironment = environment;
  logger.i('应用环境已设置为: $_currentEnvironment');
}

/// 初始化依赖注入
Future<void> init({Environment environment = Environment.development}) async {
  try {
    // 设置环境
    setEnvironment(environment);

    // 初始化关键依赖
    await initCriticalDependencies();

    // 初始化非关键依赖
    await initNonCriticalDependencies();

    logger.i('依赖注入初始化完成，环境: $environment');
  } catch (e, stackTrace) {
    logger.f('依赖注入初始化失败', e, stackTrace);
    rethrow;
  }
}

/// 初始化关键依赖 - 启动应用必须的组件
Future<void> initCriticalDependencies() async {
  try {
    logger.d('初始化关键依赖...');

    // 初始化外部依赖
    await _initExternalDependencies();

    // 注册网络信息服务
    sl.registerLazySingleton<NetworkInfo>(() => MockNetworkInfoImpl());

    // 注册核心数据源
    _registerCoreDataSources();

    // 注册核心仓库
    _registerCoreRepositories();

    // 注册核心用例
    _registerCoreUseCases();

    // 注册核心BLoC
    _registerCoreBlocs();

    logger.d('关键依赖初始化完成');
  } catch (e, stackTrace) {
    logger.e('初始化关键依赖失败', e, stackTrace);
    rethrow;
  }
}

/// 初始化非关键依赖 - 可以延迟加载的组件
Future<void> initNonCriticalDependencies() async {
  try {
    logger.d('初始化非关键依赖...');

    // 注册次要数据源
    _registerSecondaryDataSources();

    // 注册次要仓库
    _registerSecondaryRepositories();

    // 注册次要用例
    _registerSecondaryUseCases();

    // 注册次要BLoC
    _registerSecondaryBlocs();

    // 注册圈子功能相关依赖
    await _registerCircleFeature();

    logger.d('非关键依赖初始化完成');
  } catch (e, stackTrace) {
    logger.e('初始化非关键依赖失败', e, stackTrace);
    // 非关键依赖失败可以继续运行
  }
}

/// 初始化外部依赖
Future<void> _initExternalDependencies() async {
  try {
    logger.d('初始化外部依赖...');

    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);

    // Dio
    sl.registerLazySingleton(() {
      logger.d('配置Dio HTTP客户端');
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);

      // 配置忽略证书验证（仅用于开发环境）
      dio.options.validateStatus = (status) {
        return status != null && status < 500;
      };

      // 添加拦截器用于日志记录
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) {
            logger.d('Dio: $object');
          },
        ),
      );

      // 应用网络监控
      NetworkMonitor.setupDioInstance(dio);

      return dio;
    });

    logger.d('外部依赖初始化完成');
  } catch (e, stackTrace) {
    logger.e('初始化外部依赖失败', e, stackTrace);
    rethrow;
  }
}

/// 注册核心数据源
void _registerCoreDataSources() {
  // 注册用户远程数据源
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  // 注册用户本地数据源
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // 注册帖子远程数据源
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(client: sl()),
  );

  // 注册帖子本地数据源
  sl.registerLazySingleton<PostLocalDataSource>(
    () => PostLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// 注册次要数据源
void _registerSecondaryDataSources() {
  // 注册消息远程数据源
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => MessageRemoteDataSourceImpl(client: sl()),
  );

  // 注册消息本地数据源
  sl.registerLazySingleton<MessageLocalDataSource>(
    () => MessageLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// 注册核心仓库
void _registerCoreRepositories() {
  // 注册用户仓库
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 注册帖子仓库
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
}

/// 注册次要仓库
void _registerSecondaryRepositories() {
  // 注册消息仓库
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
}

/// 注册核心用例
void _registerCoreUseCases() {
  // 用户相关用例
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // 帖子相关用例
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
}

/// a注册次要用例
void _registerSecondaryUseCases() {
  // 消息相关用例
  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
}

/// 注册核心BLoC
void _registerCoreBlocs() {
  // 使用环境相关的注册方式
  switch (_currentEnvironment) {
    case Environment.development:
      _registerDevBlocs();
      break;
    case Environment.testing:
      _registerTestBlocs();
      break;
    case Environment.production:
      _registerProdBlocs();
      break;
  }
}

/// 注册开发环境的BLoC
void _registerDevBlocs() {
  // 基本的注册方式保持不变
  // 注册AuthBloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      sharedPreferences: sl(),
    ),
  );

  // 注册SquareBloc
  sl.registerFactory(() => SquareBloc(postRepository: sl()));
}

/// 注册测试环境的BLoC
void _registerTestBlocs() {
  // 在测试环境中使用的特殊BLoC注册
  // 可以覆盖一些BLoC为测试专用的实现
}

/// 注册生产环境的BLoC
void _registerProdBlocs() {
  // 生产环境的BLoC配置
  // 可能包含更多的性能优化和安全检查
}

/// 注册次要BLoC
void _registerSecondaryBlocs() {
  // 注册PostDetailBloc - 使用registerFactoryParam创建需要加载特定帖子的BLoC
  sl.registerFactoryParam<PostDetailBloc, String, void>((postId, _) {
    // 确保创建的PostRepository和加载的Post对象在处理可能为null的字段时安全
    final bloc = PostDetailBloc(postRepository: sl());
    // 加载事件由调用者处理，而不是在这里添加
    return bloc;
  });

  // 注册SquareSearchBloc
  sl.registerFactory(() => SquareSearchBloc(postRepository: sl()));

  // 注册UserSearchBloc
  sl.registerFactory(
    () => UserSearchBloc(userRepository: sl(), sharedPreferences: sl()),
  );

  // Register ChatBloc here
  sl.registerFactory(() => ChatBloc());
}

/// 注册圈子相关的依赖
Future<void> _registerCircleFeature() async {
  // BLoC
  sl.registerFactory(() => CircleBloc(repository: sl()));

  // 注册圈子仓库
  sl.registerLazySingleton<CircleRepository>(
    () => CircleRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // 注册圈子数据源
  sl.registerLazySingleton<CircleRemoteDataSource>(
    () => CircleRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CircleLocalDataSource>(
    () => CircleLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

// 用户相关的临时实现

/// 用户远程数据源接口
abstract class UserRemoteDataSource {
  Future<User> login(String username, String password);
  Future<User> register(String username, String password, String nickname);
  Future<User> getCurrentUser();
}

/// 用户远程数据源实现
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<User> login(String username, String password) async {
    return User(
      id: '1',
      username: username,
      nickname: '模拟用户',
      avatar: 'https://i.pravatar.cc/150?u=user1',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<User> register(
    String username,
    String password,
    String nickname,
  ) async {
    return User(
      id: '1',
      username: username,
      nickname: nickname,
      avatar: 'https://i.pravatar.cc/150?u=user1',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<User> getCurrentUser() async {
    return User(
      id: '1',
      username: 'user',
      nickname: '当前用户',
      avatar: 'https://i.pravatar.cc/150?u=user1',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
}

/// 用户本地数据源接口
abstract class UserLocalDataSource {
  Future<User> getCachedUser();
  Future<void> cacheUser(User user);
  Future<void> clearUser();
}

/// 用户本地数据源实现
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<User> getCachedUser() async {
    return User(
      id: '1',
      username: 'cached_user',
      nickname: '缓存用户',
      avatar: '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<void> cacheUser(User user) async {
    // 实际应用中，这里会存储用户信息到SharedPreferences
  }

  @override
  Future<void> clearUser() async {
    // 实际应用中，这里会清除SharedPreferences中的用户信息
  }
}

/// 用户仓库实现
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(username, password);
        await localDataSource.cacheUser(user);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(message: "登录失败：${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure(message: "网络连接失败"));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String username,
    String password,
    String nickname,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.register(
          username,
          password,
          nickname,
        );
        await localDataSource.cacheUser(user);
        return Right(user);
      } catch (e) {
        return Left(ServerFailure(message: "注册失败：${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure(message: "网络连接失败"));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: "获取用户信息失败"));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserInfo(User user) async {
    return Right(user);
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    return const Right('https://i.pravatar.cc/150?u=user1');
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(
    String keyword,
    int page,
    int pageSize,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // 模拟搜索结果
        final users = <User>[];

        // 生成一些模拟用户
        for (int i = 0; i < pageSize; i++) {
          // 如果页数过大，则返回更少的结果表示已到末尾
          if (page > 3 && i > pageSize / 2) break;

          // 用户ID基于关键词和索引
          final userId = 'user_${keyword.hashCode}_${page}_$i';

          users.add(
            User(
              id: userId,
              username: 'user_$i',
              nickname: '$keyword的搜索结果 $i',
              avatar: 'https://i.pravatar.cc/150?u=user$i',
              bio: '这是用户$i的简介，搜索关键词: $keyword',
              followingCount: i * 10,
              followerCount: i * 5,
              isFollowed: i % 3 == 0,
              createdAt: DateTime.now().subtract(Duration(days: i + page)),
              lastLoginAt: DateTime.now().subtract(Duration(hours: i)),
            ),
          );
        }

        return Right(users);
      } catch (e) {
        return Left(ServerFailure(message: "搜索用户失败：${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure(message: "网络连接失败"));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowings(
    String userId,
    int page,
    int pageSize,
  ) async {
    return Right([]);
  }

  @override
  Future<Either<Failure, List<User>>> getFollowers(
    String userId,
    int page,
    int pageSize,
  ) async {
    return Right([]);
  }

  @override
  Future<Either<Failure, bool>> followUser(String userId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> unfollowUser(String userId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(message: "登出失败"));
    }
  }
}

// 消息相关的临时实现

/// 消息远程数据源接口
abstract class MessageRemoteDataSource {
  Future<List<Conversation>> getConversations();
  Future<List<Message>> getMessages(
    String conversationId,
    int page,
    int pageSize,
  );
  Future<Message> sendMessage(Message message);
}

/// 消息远程数据源实现
class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final Dio client;

  MessageRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Conversation>> getConversations() async {
    return [];
  }

  @override
  Future<List<Message>> getMessages(
    String conversationId,
    int page,
    int pageSize,
  ) async {
    return [];
  }

  @override
  Future<Message> sendMessage(Message message) async {
    return message;
  }
}

/// 消息本地数据源接口
abstract class MessageLocalDataSource {
  Future<List<Conversation>> getCachedConversations();
  Future<void> cacheConversations(List<Conversation> conversations);
  Future<List<Message>> getCachedMessages(String conversationId);
  Future<void> cacheMessages(String conversationId, List<Message> messages);
}

/// 消息本地数据源实现
class MessageLocalDataSourceImpl implements MessageLocalDataSource {
  final SharedPreferences sharedPreferences;

  MessageLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Conversation>> getCachedConversations() async {
    return [];
  }

  @override
  Future<void> cacheConversations(List<Conversation> conversations) async {
    // 实际应用中，这里会存储会话列表到SharedPreferences
  }

  @override
  Future<List<Message>> getCachedMessages(String conversationId) async {
    return [];
  }

  @override
  Future<void> cacheMessages(
    String conversationId,
    List<Message> messages,
  ) async {
    // 实际应用中，这里会存储消息列表到SharedPreferences
  }
}

/// 消息仓库实现
class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;
  final MessageLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MessageRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
    int page,
    int pageSize,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    return Right(message);
  }

  @override
  Future<Either<Failure, Conversation>> createConversation(
    receiverId,
    ConversationType type,
  ) async {
    return Right(
      Conversation(
        id: '1',
        name: '新会话',
        avatar: '',
        lastMessage: null,
        unreadCount: 0,
        lastMessageTime: DateTime.now(),
        participantIds: [receiverId is String ? receiverId : '1'],
        type: type,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String messageId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> markConversationAsRead(
    String conversationId,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(String messageId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(
    String conversationId,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> pinConversation(
    String conversationId,
    bool isPinned,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> muteConversation(
    String conversationId,
    bool isMuted,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    return const Right(0);
  }
}

// 帖子相关的临时实现

/// 帖子远程数据源接口
abstract class PostRemoteDataSource {
  Future<List<Post>> getPosts(int page, int pageSize);
  Future<Post> getPostDetail(String postId);
  Future<Post> createPost(
    String title,
    String content,
    List<String> images,
    List<String> topics,
  );
}

/// 帖子远程数据源实现
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio client;

  PostRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Post>> getPosts(int page, int pageSize) async {
    // 创建默认的模拟数据
    final List<Post> posts = [];

    // 生成帖子数量 = pageSize
    for (int i = 0; i < pageSize; i++) {
      final postId = 'default_${page}_$i';
      final bool hasImages = i % 3 != 0;

      posts.add(
        Post(
          id: postId,
          userId: 'user_$i',
          username: '用户 $i',
          userAvatar: 'https://i.pravatar.cc/150?u=user1',
          title: '帖子标题 $i',
          content: '这是一条默认广场的帖子内容。这是第 $page 页的第 $i 个帖子。' * (i % 3 + 1),
          images:
              hasImages
                  ? List.generate(
                    i % 4 + 1,
                    (index) => 'https://i.pravatar.cc/150?u=image$i',
                  )
                  : [],
          topics: ['全部', '话题$i', '标签${i % 5}'],
          likeCount: i * 10 + page,
          commentCount: i * 5 + page,
          shareCount: i * 3,
          isLiked: i % 3 == 0,
          createdAt: DateTime.now().subtract(Duration(days: i, hours: page)),
          updatedAt: DateTime.now().subtract(Duration(days: i, hours: page)),
        ),
      );
    }

    return posts;
  }

  @override
  Future<Post> getPostDetail(String postId) async {
    return Post(
      id: postId,
      title: '帖子标题',
      content: '帖子内容',
      images: [
        'https://i.pravatar.cc/150?u=image1',
        'https://i.pravatar.cc/150?u=image2',
      ],
      userId: '1',
      username: 'user',
      userAvatar: 'https://i.pravatar.cc/150?u=user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commentCount: 0,
      likeCount: 0,
      isLiked: false,
      topics: [],
    );
  }

  @override
  Future<Post> createPost(
    String title,
    String content,
    List<String> images,
    List<String> topics,
  ) async {
    return Post(
      id: '1',
      title: title,
      content: content,
      images: images,
      userId: '1',
      username: 'user',
      userAvatar: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commentCount: 0,
      likeCount: 0,
      isLiked: false,
      topics: topics,
    );
  }
}

/// 帖子本地数据源接口
abstract class PostLocalDataSource {
  Future<List<Post>> getCachedPosts();
  Future<void> cachePosts(List<Post> posts);
  Future<Post?> getCachedPostDetail(String postId);
  Future<void> cachePostDetail(Post post);
}

/// 帖子本地数据源实现
class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Post>> getCachedPosts() async {
    return [];
  }

  @override
  Future<void> cachePosts(List<Post> posts) async {
    // 实际应用中，这里会存储帖子列表到SharedPreferences
  }

  @override
  Future<Post?> getCachedPostDetail(String postId) async {
    return null;
  }

  @override
  Future<void> cachePostDetail(Post post) async {
    // 实际应用中，这里会存储帖子详情到SharedPreferences
  }
}

/// 帖子仓库实现
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts(int page, int pageSize) async {
    // 创建默认的模拟数据
    final List<Post> posts = [];

    // 生成帖子数量 = pageSize
    for (int i = 0; i < pageSize; i++) {
      final postId = 'default_${page}_$i';
      final bool hasImages = i % 3 != 0;

      posts.add(
        Post(
          id: postId,
          userId: 'user_$i',
          username: '用户 $i',
          userAvatar: 'https://i.pravatar.cc/150?u=user1',
          title: '帖子标题 $i',
          content: '这是一条默认广场的帖子内容。这是第 $page 页的第 $i 个帖子。' * (i % 3 + 1),
          images:
              hasImages
                  ? List.generate(
                    i % 4 + 1,
                    (index) => 'https://i.pravatar.cc/150?u=image$i',
                  )
                  : [],
          topics: ['全部', '话题$i', '标签${i % 5}'],
          likeCount: i * 10 + page,
          commentCount: i * 5 + page,
          shareCount: i * 3,
          isLiked: i % 3 == 0,
          createdAt: DateTime.now().subtract(Duration(days: i, hours: page)),
          updatedAt: DateTime.now().subtract(Duration(days: i, hours: page)),
        ),
      );
    }

    return Right(posts);
  }

  @override
  Future<Either<Failure, List<Post>>> getFollowingPosts(
    int page,
    int pageSize,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Post>>> getUserPosts(
    String userId,
    int page,
    int pageSize,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Post>> getPostDetail(String postId) async {
    if (await networkInfo.isConnected) {
      try {
        final post = await remoteDataSource.getPostDetail(postId);
        // 确保关键字段不为null
        final safePost = Post(
          id: post.id,
          userId: post.userId,
          username: post.username,
          userAvatar: post.userAvatar ?? '', // 确保不为null
          title: post.title ?? '',
          content: post.content ?? '',
          images: post.images ?? [],
          topics: post.topics ?? [],
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          shareCount: post.shareCount,
          isLiked: post.isLiked,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );
        return Right(safePost);
      } catch (e) {
        return Left(ServerFailure(message: "获取帖子详情失败：${e.toString()}"));
      }
    } else {
      try {
        final post = await localDataSource.getCachedPostDetail(postId);
        if (post != null) {
          return Right(post);
        } else {
          return Left(CacheFailure(message: "没有缓存的帖子详情"));
        }
      } catch (e) {
        return Left(CacheFailure(message: "获取缓存帖子详情失败"));
      }
    }
  }

  @override
  Future<Either<Failure, Post>> createPost(
    String title,
    String content,
    List<String> images,
    List<String> topics,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final post = await remoteDataSource.createPost(
          title,
          content,
          images,
          topics,
        );
        return Right(post);
      } catch (e) {
        return Left(ServerFailure(message: "发布帖子失败：${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure(message: "网络连接失败"));
    }
  }

  @override
  Future<Either<Failure, Post>> updatePost(
    String postId,
    String title,
    String content,
    List<String> topics,
  ) async {
    return Left(ServerFailure(message: "暂未实现"));
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> likePost(String postId, bool isLike) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(
    String postId,
    int page,
    int pageSize,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Comment>> createComment(
    String postId,
    String content, {
    String? parentId,
    String? replyToUserId,
  }) async {
    return Right(
      Comment(
        id: '1',
        content: content,
        postId: postId,
        userId: '1',
        username: 'user',
        userAvatar: '',
        createdAt: DateTime.now(),
        likeCount: 0,
        isLiked: false,
        parentId: parentId,
        replyToUserId: replyToUserId,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> deleteComment(String commentId) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> likeComment(
    String commentId,
    bool isLike,
  ) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<String>>> getHotTopics(int limit) async {
    return Right(['热门话题1', '热门话题2', '热门话题3']);
  }

  @override
  Future<Either<Failure, List<Post>>> getPostsByTopic(
    String topic,
    int page,
    int pageSize,
  ) async {
    // 创建不同主题的模拟数据
    final List<Post> posts = [];

    // 根据话题生成不同的内容
    final String topicContent =
        topic == '热门'
            ? '这是一条热门话题的帖子内容。'
            : topic == '本地'
            ? '这是一条本地话题的帖子内容。'
            : topic == '关注'
            ? '这是一条关注话题的帖子内容。'
            : '这是一条普通话题的帖子内容。';

    // 生成帖子数量 = pageSize
    for (int i = 0; i < pageSize; i++) {
      final postId = '${topic}_${page}_$i';
      final bool hasImages = i % 3 != 0;

      posts.add(
        Post(
          id: postId,
          userId: 'user_$i',
          username: '$topic 用户 $i',
          userAvatar: 'https://i.pravatar.cc/150?u=user1',
          title: '$topic 帖子标题 $i',
          content: '$topicContent 这是第 $page 页的第 $i 个帖子。' * (i % 3 + 1),
          images:
              hasImages
                  ? List.generate(
                    i % 4 + 1,
                    (index) => 'https://i.pravatar.cc/150?u=image$i',
                  )
                  : [],
          topics: [topic, '话题$i', '标签${i % 5}'],
          likeCount: i * 10 + page,
          commentCount: i * 5 + page,
          shareCount: i * 3,
          isLiked: i % 3 == 0,
          createdAt: DateTime.now().subtract(Duration(days: i, hours: page)),
          updatedAt: DateTime.now().subtract(Duration(days: i, hours: page)),
        ),
      );
    }

    return Right(posts);
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(
    String keyword,
    int page,
    int pageSize,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        // 模拟搜索结果
        final List<Post> searchResults = [];

        // 生成搜索结果数量 = pageSize（如果是第一页）或更少（如果是后续页）
        final int resultCount = page > 2 ? (pageSize ~/ page) : pageSize;

        for (int i = 0; i < resultCount; i++) {
          final postId = 'search_${page}_$i';
          final bool hasImages = i % 3 != 0;

          searchResults.add(
            Post(
              id: postId,
              userId: 'user_$i',
              username: '用户 $i',
              userAvatar: 'https://i.pravatar.cc/150?u=user$i',
              title: '包含"$keyword"的帖子 $i',
              content:
                  '这是一条包含搜索关键词"$keyword"的帖子内容。这是第 $page 页的第 $i 个搜索结果。' *
                  (i % 3 + 1),
              images:
                  hasImages
                      ? List.generate(
                        i % 4 + 1,
                        (index) => 'https://i.pravatar.cc/150?u=image$i',
                      )
                      : [],
              topics: ['搜索', keyword, '标签${i % 5}'],
              likeCount: i * 10 + page,
              commentCount: i * 5 + page,
              shareCount: i * 3,
              isLiked: i % 3 == 0,
              createdAt: DateTime.now().subtract(
                Duration(days: i, hours: page),
              ),
              updatedAt: DateTime.now().subtract(
                Duration(days: i, hours: page),
              ),
            ),
          );
        }

        return Right(searchResults);
      } catch (e) {
        return Left(ServerFailure(message: "搜索帖子失败：${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure(message: "网络连接失败"));
    }
  }
}

// 添加懒加载服务注册器
T registerLazySingleton<T extends Object>({
  required T Function() factory,
  String? instanceName,
}) {
  if (!sl.isRegistered<T>(instanceName: instanceName)) {
    sl.registerLazySingleton<T>(() => factory(), instanceName: instanceName);
  }
  return sl<T>(instanceName: instanceName);
}

// 添加环境特定的服务注册
T registerForEnvironment<T extends Object>({
  required T Function() devFactory,
  required T Function() prodFactory,
  T Function()? testFactory,
  String? instanceName,
}) {
  final factory = switch (_currentEnvironment) {
    Environment.development => devFactory,
    Environment.testing => testFactory ?? devFactory,
    Environment.production => prodFactory,
  };

  return registerLazySingleton<T>(factory: factory, instanceName: instanceName);
}
