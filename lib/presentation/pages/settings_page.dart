import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_event.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_event.dart';
import 'package:text_sphere_app/presentation/blocs/theme/theme_state.dart';
import 'package:text_sphere_app/core/cache/cache_manager.dart' as app_cache;
import 'package:text_sphere_app/utils/strategic_image_cache.dart';
import 'package:text_sphere_app/utils/performance_utils.dart';
import 'package:text_sphere_app/utils/offline_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationsEnabled = true;
  bool _isLocationEnabled = true;
  String _cacheSize = "计算中...";
  bool _isClearingCache = false;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  // 计算缓存大小
  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      final tempSize = await _calculateDirectorySize(tempDir);
      final cacheSize = await _calculateDirectorySize(cacheDir);

      final totalSize = tempSize + cacheSize;
      final sizeString = _formatBytes(totalSize);

      if (mounted) {
        setState(() {
          _cacheSize = sizeString;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = "无法计算";
        });
      }
    }
  }

  // 计算目录大小
  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating size: $e');
    }
    return totalSize;
  }

  // 格式化字节大小为可读形式
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // 清理缓存
  Future<void> _clearCache() async {
    if (_isClearingCache) return;

    setState(() {
      _isClearingCache = true;
    });

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text('正在清理缓存...'),
              ],
            ),
          );
        },
      );

      // 清理各种缓存
      await DefaultCacheManager().emptyCache();
      app_cache.CacheManager().clearMemoryCache();
      app_cache.CacheManager().clearApiCache();
      StrategicImageCache().clearAllCache();
      PerformanceUtils.clearImageCache();
      await OfflineManager().clearAllCaches();

      // 清理临时目录
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectoryContents(tempDir);
      }

      // 清理缓存目录
      final cacheDir = await getApplicationCacheDirectory();
      if (await cacheDir.exists()) {
        await _deleteDirectoryContents(cacheDir);
      }

      // 关闭对话框
      Navigator.of(context).pop();

      // 更新缓存大小
      await _calculateCacheSize();

      // 显示清理完成提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('缓存清理完成')));
    } catch (e) {
      // 关闭对话框
      Navigator.of(context).pop();

      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('清理缓存时出错: $e')));
    } finally {
      setState(() {
        _isClearingCache = false;
      });
    }
  }

  // 删除目录内容
  Future<void> _deleteDirectoryContents(Directory directory) async {
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: false)) {
          if (entity is Directory) {
            await entity.delete(recursive: true);
          } else if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Error deleting directory contents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('设置'), centerTitle: true, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('账户'),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: '个人资料',
                onTap: () {
                  // 跳转到个人资料编辑页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('个人资料功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.shield_outlined,
                title: '会员中心',
                onTap: () {
                  // 跳转到会员中心页面
                  context.push('/membership');
                },
              ),
              _buildSettingItem(
                icon: Icons.security_outlined,
                title: '账户安全',
                onTap: () {
                  // 跳转到账户安全页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('账户安全功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: '隐私设置',
                onTap: () {
                  // 跳转到隐私设置页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('隐私设置功能暂未实现')));
                },
              ),
              _buildDivider(),

              _buildSectionTitle('偏好设置'),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return _buildSwitchItem(
                    icon: Icons.dark_mode_outlined,
                    title: '深色模式',
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      // 切换深色模式
                      context.read<ThemeBloc>().add(SetTheme(isDark: value));
                    },
                  );
                },
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return _buildSettingItem(
                    icon: Icons.color_lens_outlined,
                    title: '主题颜色',
                    subtitle:
                        AppTheme.themeColors[state.themeColorKey]?.name ?? '紫色',
                    onTap: () {
                      _showThemeColorPicker(context, state.themeColorKey);
                    },
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: '通知设置',
                onTap: () {
                  // 跳转到通知设置页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('通知设置功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: '语言设置',
                onTap: () {
                  // 跳转到语言设置页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('语言设置功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.cleaning_services_outlined,
                title: '清理缓存',
                subtitle: _cacheSize,
                onTap: _clearCache,
              ),
              _buildDivider(),

              _buildSectionTitle('关于'),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: () {
                  // 跳转到关于我们页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('关于我们功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: '帮助与反馈',
                onTap: () {
                  // 跳转到帮助与反馈页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('帮助与反馈功能暂未实现')));
                },
              ),
              _buildSettingItem(
                icon: Icons.policy_outlined,
                title: '隐私政策',
                onTap: () {
                  // 跳转到隐私政策页面
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('隐私政策功能暂未实现')));
                },
              ),
              _buildDivider(),

              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  color: theme.colorScheme.errorContainer.withOpacity(0.2),
                  child: InkWell(
                    onTap: () => _showLogoutConfirmDialog(context),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: theme.colorScheme.error,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              '退出登录',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: theme.colorScheme.error.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  'Text Sphere v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 24.h, bottom: 8.h, right: 24.w),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Divider(color: theme.dividerColor.withOpacity(0.5), height: 1),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('退出登录'),
            content: Text('确定要退出当前账号吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // 执行退出登录操作
                  context.read<AuthBloc>().add(const LogoutEvent());

                  // 导航到登录页
                  context.go('/login');
                },
                child: Text('确定', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showThemeColorPicker(BuildContext context, String currentColorKey) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('选择主题颜色'),
            content: SizedBox(
              width: 300.w,
              height: 300.h,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: AppTheme.themeColors.length,
                itemBuilder: (context, index) {
                  final colorEntry = AppTheme.themeColors.entries.elementAt(
                    index,
                  );
                  final colorKey = colorEntry.key;
                  final themeColor = colorEntry.value;
                  final isSelected = colorKey == currentColorKey;

                  return InkWell(
                    onTap: () {
                      context.read<ThemeBloc>().add(
                        SetThemeColor(colorKey: colorKey),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? themeColor.primary
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: themeColor.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 24.r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: themeColor.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 24.r,
                                height: 24.r,
                                decoration: BoxDecoration(
                                  color: themeColor.tertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            themeColor.name,
                            style: TextStyle(
                              color: themeColor.primary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: themeColor.primary,
                              size: 20.r,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
            ],
          ),
    );
  }
}
