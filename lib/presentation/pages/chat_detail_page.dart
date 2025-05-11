import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/presentation/blocs/chat/chat_bloc.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/chat_message_bubble.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';
import 'package:text_sphere_app/presentation/widgets/error_view.dart';
import 'package:text_sphere_app/core/di/injection_container.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  final FocusNode _focusNode = FocusNode();
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<ChatBloc>()..add(LoadChat(widget.chatId));

    _chatBloc.stream.listen((state) {
      if (state.status == ChatStatus.loaded) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <
              _scrollController.position.maxScrollExtent - 50 &&
          _focusNode.hasFocus) {
        _focusNode.unfocus();
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _chatBloc.add(SendMessage(_messageController.text));
    _messageController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.colorScheme.background
              : theme.colorScheme.surface.withOpacity(0.95),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: BlocBuilder<ChatBloc, ChatState>(
          bloc: _chatBloc,
          builder: (context, state) {
            return _buildAppBar(context, state.partner);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.colorScheme.background
                          : theme.colorScheme.surface.withOpacity(0.95),
                ),
                child: BlocBuilder<ChatBloc, ChatState>(
                  bloc: _chatBloc,
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return Center(
                        child: LoadingIndicator(
                          size: 40.r,
                          color: theme.colorScheme.primary,
                          message: '加载聊天内容...',
                        ),
                      );
                    } else if (state.status == ChatStatus.error) {
                      return Center(
                        child: ErrorView(
                          message: state.errorMessage ?? '加载聊天失败',
                          onRetry: () => _chatBloc.add(LoadChat(widget.chatId)),
                        ),
                      );
                    } else if (state.status == ChatStatus.loaded) {
                      if (state.messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64.sp,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.5,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                '没有聊天记录',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '发送消息开始聊天吧',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return _buildMessageList(state.messages, state.partner);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            _buildInputArea(),
            if (_showEmojiPicker) _buildEmojiPicker(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ChatPartner? partner) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 假设partner是在线的
    final bool isOnline = true;

    return AppBar(
      backgroundColor:
          isDark
              ? theme.appBarTheme.backgroundColor
              : theme.colorScheme.surface,
      elevation: 0.5,
      toolbarHeight: 70.h,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: theme.iconTheme.color,
          size: 20.sp,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home/messages');
          }
        },
      ),
      title:
          partner == null
              ? const SizedBox.shrink()
              : Row(
                children: [
                  // 头像和在线状态
                  Stack(
                    children: [
                      AppAvatar(
                        imageUrl: partner.avatarUrl,
                        size: 48,
                        placeholderText: partner.name[0],
                        borderWidth: 0,
                        useShimmer: true,
                      ),
                      // 在线状态指示器
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12.r,
                            height: 12.r,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.r,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          partner.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isOnline ? '在线' : '离线',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: theme.iconTheme.color,
            size: 24.sp,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildChatOptions(),
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages, ChatPartner? partner) {
    final theme = Theme.of(context);

    // 创建日期分组
    Map<String, List<ChatMessage>> groupedMessages = {};
    for (var message in messages) {
      // 将time字符串转换为临时的日期用于分组
      final DateTime messageTime = _parseTimeString(message.time);
      final date = _getDateString(messageTime);
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    // 排序日期
    final sortedDates =
        groupedMessages.keys.toList()..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateMessages = groupedMessages[date]!;

        return Column(
          children: [
            // 日期分隔线
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Divider(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                ],
              ),
            ),

            // 消息列表
            ...dateMessages.map((message) {
              return Column(
                children: [
                  ChatMessageBubble(message: message, partner: partner),

                  // 消息时间
                  Padding(
                    padding: EdgeInsets.only(
                      left: message.isMe ? 0 : 46.w,
                      right: message.isMe ? 0 : 0,
                      top: 2.h,
                      bottom: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          message.isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        // 消息发送状态图标（对于自己发的消息）
                        if (message.isMe)
                          Icon(
                            Icons.done_all, // 假设所有消息都已读
                            size: 14.sp,
                            color: theme.colorScheme.primary,
                          ),
                        if (message.isMe) SizedBox(width: 4.w),
                        Text(
                          message.time,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
              color: theme.colorScheme.primary,
              size: 24.sp,
            ),
            onPressed: () {
              _focusNode.unfocus();
              setState(() {
                _showEmojiPicker = !_showEmojiPicker;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 100.h),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onTap: () {
                  setState(() {
                    _showEmojiPicker = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(color: theme.hintColor, fontSize: 14.sp),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  filled: true,
                  fillColor:
                      isDark
                          ? theme.colorScheme.surfaceVariant
                          : Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              return Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  onPressed: value.text.trim().isNotEmpty ? _sendMessage : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final theme = Theme.of(context);

    return Container(
      height: 250.h,
      color: theme.colorScheme.surface,
      padding: EdgeInsets.all(16.r),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 12.r,
          crossAxisSpacing: 12.r,
        ),
        itemCount: 24, // 表情数量
        itemBuilder: (context, index) {
          // 模拟表情
          return GestureDetector(
            onTap: () {
              // 插入表情到输入框
              _messageController.text += '😊';
            },
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text('😊', style: TextStyle(fontSize: 24.sp)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatOptions() {
    final theme = Theme.of(context);

    List<Map<String, dynamic>> options = [
      {'icon': Icons.person, 'title': '查看资料'},
      {'icon': Icons.search, 'title': '搜索消息'},
      {'icon': Icons.notifications_off, 'title': '静音通知'},
      {'icon': Icons.delete, 'title': '清空聊天记录', 'isDestructive': true},
      {'icon': Icons.block, 'title': '屏蔽此用户', 'isDestructive': true},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          ...options.map((option) {
            final bool isDestructive = option['isDestructive'] ?? false;

            return ListTile(
              leading: Icon(
                option['icon'],
                color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
              ),
              title: Text(
                option['title'],
                style: TextStyle(
                  color:
                      isDestructive ? Colors.red : theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${option['title']}功能开发中')),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // 辅助方法：解析时间字符串
  DateTime _parseTimeString(String time) {
    // 获取今天的日期
    final now = DateTime.now();
    // 解析时间字符串 (假设格式为 "HH:MM")
    final parts = time.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
    return now;
  }

  // 辅助方法：获取日期字符串
  String _getDateString(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '今天';
    } else if (messageDate == yesterday) {
      return '昨天';
    } else {
      return '${timestamp.year}-${timestamp.month}-${timestamp.day}';
    }
  }

  // 辅助方法：获取时间字符串
  String _getTimeString(DateTime timestamp) {
    String hour = timestamp.hour.toString().padLeft(2, '0');
    String minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
