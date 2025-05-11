import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/core/di/injection_container.dart' as di;
import 'package:text_sphere_app/core/router/app_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_event.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_event.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_state.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_event.dart';
import 'package:flutter/services.dart';
import 'package:text_sphere_app/utils/performance_utils.dart';
import 'package:text_sphere_app/utils/app_resources.dart';
import 'package:text_sphere_app/utils/app_layout.dart';
import 'package:text_sphere_app/utils/strategic_image_cache.dart';
import 'package:text_sphere_app/utils/app_startup_manager.dart';
import 'package:text_sphere_app/utils/app_logger.dart' hide AppExceptionHandler;
import 'package:text_sphere_app/utils/bloc_logger.dart';
import 'package:text_sphere_app/utils/exception_wrapper.dart';
import 'package:text_sphere_app/utils/analytics/user_action_tracker.dart';
import 'dart:async';
import 'package:text_sphere_app/utils/offline_manager.dart';

// SSL证书验证配置
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // 允许所有证书
  }
}

void main() async {
  // 使用Zone捕获全局异常
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 初始化日志系统
      logger.init(
        enabled: true,
        minLevel: LogLevel.debug,
        showStack: true,
        showTimestamp: true,
        logInProduction: false,
      );

      // 初始化全局异常处理
      AppExceptionHandler.init();

      // 设置Bloc观察者用于日志记录
      Bloc.observer = AppBlocObserver(
        verbose: false, // 在开发时可以设置为true获取更详细的日志
      );

      logger.i('应用启动中...');

      // 初始化用户行为跟踪器
      await UserActionTracker().init();

      // 设置全局HTTP配置，忽略证书验证错误
      HttpOverrides.global = MyHttpOverrides();

      // 设置设备方向，限制为竖屏模式提高性能
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // 设置系统UI模式，优化状态栏外观
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // 使用AppRouter中的全局导航键
      final navigatorKey = AppRouter.navigatorKey;

      // 设置全局导航键
      StrategicImageCache.setNavigatorKey(navigatorKey);
      PerformanceUtils.setNavigatorKey(navigatorKey);

      // 初始化图片缓存管理
      StrategicImageCache().init();

      // 使用应用启动管理器初始化应用
      await logger.logExecutionTime('应用启动初始化', () async {
        return AppStartupManager.init(
          preloadImages: [
            AppResources.logoPath,
            AppResources.placeholderPath,
            AppResources.errorImagePath,
          ],
          optimizeForPerformance: true,
          enableCriticalPathOptimization: true,
        );
      });

      // 初始化离线管理器
      try {
        logger.i('正在初始化离线管理器...');
        final offlineManager = OfflineManager();
        await offlineManager.init();
        logger.i('离线管理器初始化完成');
      } catch (e) {
        logger.e('离线管理器初始化失败: $e');
      }

      // 加载环境变量
      await dotenv.load(fileName: '.env').catchError((error) {
        logger.w('无法加载环境变量: $error');
        return null;
      });

      // 仅初始化关键依赖
      await logger.logExecutionTime('依赖初始化', () async {
        return di.initCriticalDependencies();
      });

      // 初始化SharedPreferences
      final sharedPreferences = await SharedPreferences.getInstance();

      // 初始化主应用
      final app = AppRoot(
        sharedPreferences: sharedPreferences,
        navigatorKey: navigatorKey,
      );

      logger.i('应用初始化完成，准备渲染UI');
      runApp(app);

      // 延迟初始化非关键依赖
      Future.microtask(() async {
        await logger.runGuarded(
          () => di.initNonCriticalDependencies(),
          operationName: '非关键依赖初始化',
        );
        logger.i("非关键依赖初始化完成");
      });
    },
    (error, stack) {
      // 处理未捕获的异步错误
      logger.f('未捕获的异步错误', error, stack);

      // 记录到用户行为跟踪
      UserActionTracker().trackError(
        '未捕获的异步错误',
        error.toString(),
        stackTrace: stack,
      );
    },
  );
}

/// 应用根组件，管理BLoC提供者
class AppRoot extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final GlobalKey<NavigatorState> navigatorKey;

  const AppRoot({
    Key? key,
    required this.sharedPreferences,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // 注册应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);

    // 释放离线管理器资源
    try {
      OfflineManager().dispose();
    } catch (e) {
      logger.e('释放离线管理器资源失败: $e');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用进入后台时清理资源
    if (state == AppLifecycleState.paused) {
      // 当应用进入后台时清除图片缓存
      PerformanceUtils.clearImageCache();
      StrategicImageCache().clearLowPriorityCache();
    } else if (state == AppLifecycleState.resumed) {
      // 应用恢复前台时的操作
      PerformanceUtils.optimizeUiPerformance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 注册主题Bloc
        BlocProvider<ThemeBloc>(
          create: (_) {
            final bloc = ThemeBloc(sharedPreferences: widget.sharedPreferences);
            // 延迟获取主题，确保ScreenUtil已初始化
            Future.microtask(() {
              bloc.add(const InitializeTheme());
            });
            return bloc;
          },
          lazy: false, // 立即创建，因为主题需要立即使用
        ),
        // 注册认证Bloc
        BlocProvider<AuthBloc>(
          create: (_) {
            final bloc = AuthBloc(
              loginUseCase: di.sl(),
              registerUseCase: di.sl(),
              getCurrentUserUseCase: di.sl(),
              sharedPreferences: widget.sharedPreferences,
            );
            bloc.add(const CheckAuthenticationEvent());
            return bloc;
          },
          lazy: false, // 认证状态需要立即检查
        ),
        // 注册SquareBloc（懒加载）
        BlocProvider<SquareBloc>(
          create: (_) {
            final bloc = di.sl<SquareBloc>();
            bloc.add(const LoadSquarePosts());
            return bloc;
          },
          lazy: true, // 懒加载
        ),
        // 其他BLoC可以在需要时创建
      ],
      child: MyApp(navigatorKey: widget.navigatorKey),
    );
  }
}

/// 自定义滚动行为，针对性能进行优化
class OptimizedScrollBehavior extends MaterialScrollBehavior {
  const OptimizedScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return PerformanceUtils.getOptimizedScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  // 这个navigatorKey应该与AppRouter中的相同
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 设计尺寸
      designSize: const Size(420, 820),
      // 完整初始化所有必要参数
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (_, widget) {
        // 在ScreenUtilInit初始化完成后初始化AppTheme
        AppTheme.initialize();

        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return RepaintBoundary(
              child: MaterialApp.router(
                title: 'Text Sphere',
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppTheme.getLightTheme(
                  themeColorKey: state.themeColorKey,
                ),
                darkTheme: AppTheme.getDarkTheme(
                  themeColorKey: state.themeColorKey,
                ),
                routerConfig: AppRouter.router,
                // 添加性能优化配置
                builder: (context, child) {
                  // 添加顶层错误捕获和性能监控
                  ErrorWidget.builder = (FlutterErrorDetails details) {
                    // 记录UI错误
                    logger.e('UI渲染错误', details.exception, details.stack);

                    return Material(
                      color: Colors.red.shade100,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppLayout.paddingM),
                          child: Text(
                            '发生错误: ${details.exception}',
                            style: TextStyle(
                              color: AppResources.errorColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  };

                  return ExceptionWrapper.wrapBuilder(
                    context: context,
                    builder:
                        (innerContext) => MediaQuery(
                          // 避免系统字体大小影响应用内字体大小
                          data: ExceptionWrapper.safeMediaQuery(
                            innerContext,
                          ).copyWith(textScaleFactor: 1.0),
                          child: child!,
                        ),
                    fallback: (error, stackTrace) {
                      logger.e('MediaQuery构建错误', error, stackTrace);
                      return child!;
                    },
                  );
                },
                // 使用优化的滚动行为
                scrollBehavior: const OptimizedScrollBehavior(),
              ),
            );
          },
        );
      },
    );
  }
}
