import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final String type; // like, comment, follow, system
  final DateTime createdAt;
  final bool isRead;
  final String? userId;
  final String? userAvatar;
  final String? postId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.userId,
    this.userAvatar,
    this.postId,
  });

  // 用于演示的数据
  static List<NotificationModel> generateMockData() {
    return [
      NotificationModel(
        id: '1',
        title: '点赞提醒',
        content: '用户张三赞了你的帖子',
        type: 'like',
        createdAt: DateTime.now().subtract(Duration(minutes: 5)),
        isRead: false,
        userId: 'user1',
        userAvatar: 'https://i.pravatar.cc/150?u=user1',
        postId: 'post1',
      ),
      NotificationModel(
        id: '2',
        title: '评论提醒',
        content: '用户李四评论了你的帖子: "这篇文章写得真好！"',
        type: 'comment',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        isRead: false,
        userId: 'user2',
        userAvatar: 'https://i.pravatar.cc/150?u=user2',
        postId: 'post2',
      ),
      NotificationModel(
        id: '3',
        title: '关注提醒',
        content: '用户王五关注了你',
        type: 'follow',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        isRead: true,
        userId: 'user3',
        userAvatar: 'https://i.pravatar.cc/150?u=user3',
      ),
      NotificationModel(
        id: '4',
        title: '系统通知',
        content: '你的帖子已被设为精选内容',
        type: 'system',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: '点赞提醒',
        content: '用户赵六赞了你的帖子',
        type: 'like',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        isRead: true,
        userId: 'user4',
        userAvatar: 'https://i.pravatar.cc/150?u=user4',
        postId: 'post3',
      ),
      NotificationModel(
        id: '6',
        title: '评论提醒',
        content: '用户钱七回复了你的评论: "非常同意你的观点"',
        type: 'comment',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        isRead: true,
        userId: 'user5',
        userAvatar: 'https://i.pravatar.cc/150?u=user5',
        postId: 'post1',
      ),
    ];
  }
}

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late List<NotificationModel> _notifications;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _notifications = NotificationModel.generateMockData();
      _isLoading = false;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(dateTime);
    }
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icon(Icons.favorite, color: Colors.red, size: 24.sp);
      case 'comment':
        return Icon(Icons.comment, color: Colors.blue, size: 24.sp);
      case 'follow':
        return Icon(Icons.person_add, color: Colors.green, size: 24.sp);
      case 'system':
        return Icon(Icons.notifications, color: Colors.orange, size: 24.sp);
      default:
        return Icon(Icons.notifications, color: Colors.grey, size: 24.sp);
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          content: _notifications[index].content,
          type: _notifications[index].type,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          userId: _notifications[index].userId,
          userAvatar: _notifications[index].userAvatar,
          postId: _notifications[index].postId,
        );
        _notifications[index] = updatedNotification;
      }
    });
  }

  void _handleNotificationTap(NotificationModel notification) {
    _markAsRead(notification.id);

    // 根据不同类型的通知跳转到不同页面
    switch (notification.type) {
      case 'like':
      case 'comment':
        if (notification.postId != null) {
          context.push('/home/square/detail/${notification.postId}');
        }
        break;
      case 'follow':
        if (notification.userId != null) {
          context.push('/profile/${notification.userId}');
        }
        break;
      case 'system':
        // 系统通知通常没有特定跳转
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '消息通知',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color:
                theme.appBarTheme.titleTextStyle?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _notifications =
                    _notifications.map((notification) {
                      return NotificationModel(
                        id: notification.id,
                        title: notification.title,
                        content: notification.content,
                        type: notification.type,
                        createdAt: notification.createdAt,
                        isRead: true,
                        userId: notification.userId,
                        userAvatar: notification.userAvatar,
                        postId: notification.postId,
                      );
                    }).toList();
              });
            },
            child: Text(
              '全部已读',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: LoadingIndicator())
              : _notifications.isEmpty
              ? _buildEmptyView()
              : _buildNotificationList(),
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64.sp,
            color: theme.disabledColor,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无消息通知',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        itemCount: _notifications.length,
        separatorBuilder:
            (context, index) =>
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(notification.type);

    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        color:
            notification.isRead
                ? Colors.transparent
                : isDark
                ? theme.colorScheme.primary.withOpacity(0.04)
                : theme.colorScheme.primary.withOpacity(0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationTypeIcon(notification.type),
                color: typeColor,
                size: 20.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 未读标记
                      if (!notification.isRead)
                        Container(
                          width: 6.r,
                          height: 6.r,
                          margin: EdgeInsets.only(right: 4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: typeColor,
                          ),
                        ),

                      // 标题
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),

                      // 时间
                      SizedBox(width: 4.w),
                      Text(
                        _formatDateTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // 内容
                  Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 移除文字操作按钮，改用箭头图标或完全移除
                  if (!notification.isRead) SizedBox(height: 6.h),
                ],
              ),
            ),

            // 右侧箭头图标
            Center(
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary.withOpacity(0.5),
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final theme = Theme.of(context);

    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return theme.colorScheme.primary;
      case 'follow':
        return Colors.green;
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.chat_bubble_rounded;
      case 'follow':
        return Icons.person_add_rounded;
      case 'system':
        return Icons.notifications_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
