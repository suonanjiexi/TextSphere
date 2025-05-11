import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/core/di/injection_container.dart' as di;
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:text_sphere_app/presentation/pages/user_search_page.dart';
import 'package:text_sphere_app/presentation/pages/chat_detail_page.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:lpinyin/lpinyin.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({Key? key}) : super(key: key);

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['聊天', '联系人'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 顶部安全区域的占位
          SizedBox(height: statusBarHeight),

          // 添加搜索框 - 紧贴顶部安全区域
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            color: theme.scaffoldBackgroundColor,
            child: Row(
              children: [
                // 搜索框
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      try {
                        final userSearchBloc = di.sl<UserSearchBloc>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    UserSearchPage(searchBloc: userSearchBloc),
                          ),
                        );
                      } catch (e) {
                        print('直接导航失败: $e');
                        try {
                          context.go('/user/search');
                        } catch (e) {
                          print('go_router导航失败: $e');
                        }
                      }
                    },
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color:
                            theme.brightness == Brightness.dark
                                ? theme.colorScheme.surfaceVariant
                                : theme.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(19.r),
                        boxShadow:
                            theme.brightness == Brightness.light
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                                : [],
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.search,
                            color: theme.hintColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '搜索好友',
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 14.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 通知按钮
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: theme.iconTheme.color,
                    size: 24.sp,
                  ),
                  onPressed: () {
                    context.push('/notifications');
                  },
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color
                  ?.withOpacity(0.7),
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),

          // Tab内容
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TabBarView(
                controller: _tabController,
                children: [_buildChats(context), _buildContacts(context)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChats(BuildContext context) {
    return _buildMessageList(context);
  }

  Widget _buildContacts(BuildContext context) {
    final theme = Theme.of(context);

    // 模拟联系人数据
    List<Map<String, dynamic>> contacts = [
      {
        'id': '1',
        'name': '李明',
        'title': '产品经理',
        'avatar': 'https://i.pravatar.cc/300?img=11',
        'isOnline': true,
        'isFavorite': true,
      },
      {
        'id': '2',
        'name': '张华',
        'title': '资深UI设计师',
        'avatar': 'https://i.pravatar.cc/300?img=12',
        'isOnline': true,
        'isFavorite': true,
      },
      {
        'id': '3',
        'name': '王伟',
        'title': '前端开发工程师',
        'avatar': 'https://i.pravatar.cc/300?img=13',
        'isOnline': false,
        'isFavorite': true,
      },
      {
        'id': '4',
        'name': '刘芳',
        'title': '项目经理',
        'avatar': 'https://i.pravatar.cc/300?img=14',
        'isOnline': false,
        'isFavorite': false,
      },
      {
        'id': '5',
        'name': '陈明',
        'title': '后端开发工程师',
        'avatar': 'https://i.pravatar.cc/300?img=15',
        'isOnline': true,
        'isFavorite': false,
      },
      {
        'id': '6',
        'name': '林小红',
        'title': '测试工程师',
        'avatar': 'https://i.pravatar.cc/300?img=16',
        'isOnline': false,
        'isFavorite': false,
      },
      {
        'id': '7',
        'name': '赵强',
        'title': '产品设计师',
        'avatar': 'https://i.pravatar.cc/300?img=17',
        'isOnline': true,
        'isFavorite': false,
      },
      {
        'id': '8',
        'name': '黄磊',
        'title': '技术总监',
        'avatar': 'https://i.pravatar.cc/300?img=18',
        'isOnline': false,
        'isFavorite': false,
      },
      {
        'id': '9',
        'name': '杨洋',
        'title': '市场总监',
        'avatar': 'https://i.pravatar.cc/300?img=19',
        'isOnline': true,
        'isFavorite': false,
      },
      {
        'id': '10',
        'name': '钱多多',
        'title': '财务经理',
        'avatar': 'https://i.pravatar.cc/300?img=20',
        'isOnline': false,
        'isFavorite': false,
      },
      {
        'id': '11',
        'name': '孙淼',
        'title': '人力资源经理',
        'avatar': 'https://i.pravatar.cc/300?img=21',
        'isOnline': true,
        'isFavorite': false,
      },
      {
        'id': '12',
        'name': '周雷',
        'title': '运维工程师',
        'avatar': 'https://i.pravatar.cc/300?img=22',
        'isOnline': false,
        'isFavorite': false,
      },
      {
        'id': '13',
        'name': '吴江',
        'title': '销售经理',
        'avatar': 'https://i.pravatar.cc/300?img=23',
        'isOnline': true,
        'isFavorite': false,
      },
      {
        'id': '14',
        'name': '郑建国',
        'title': '安全工程师',
        'avatar': 'https://i.pravatar.cc/300?img=24',
        'isOnline': false,
        'isFavorite': false,
      },
    ];

    if (contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              '暂无联系人',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      );
    }

    // 为每个联系人添加拼音信息并按拼音首字母排序
    for (var contact in contacts) {
      // 获取中文名字的拼音首字母
      String pinyin = PinyinHelper.getPinyinE(
        contact['name'],
        separator: ' ',
        format: PinyinFormat.WITHOUT_TONE,
      );
      String firstLetter = pinyin.substring(0, 1).toUpperCase();
      contact['pinyinFirstLetter'] = firstLetter;
    }

    // 按拼音首字母排序
    contacts.sort(
      (a, b) => a['pinyinFirstLetter'].compareTo(b['pinyinFirstLetter']),
    );

    // 生成字母索引和分组
    Map<String, List<Map<String, dynamic>>> groupedContacts = {};
    List<String> indexList = [];

    for (var contact in contacts) {
      String letter = contact['pinyinFirstLetter'];
      if (!groupedContacts.containsKey(letter)) {
        groupedContacts[letter] = [];
        indexList.add(letter);
      }
      groupedContacts[letter]!.add(contact);
    }

    // 创建一个滚动控制器，用于跳转到特定字母分组
    final ScrollController scrollController = ScrollController();
    // 创建一个键值映射，保存每个字母分组的全局键
    Map<String, GlobalKey> letterKeys = {};
    for (var letter in indexList) {
      letterKeys[letter] = GlobalKey();
    }

    return Stack(
      children: [
        // 联系人列表
        ListView(
          controller: scrollController,
          children: [
            // 按字母分组显示联系人
            for (var letter in indexList) ...[
              // 字母标题
              Container(
                key: letterKeys[letter],
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                color:
                    theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              // 该字母下的联系人
              ...groupedContacts[letter]!.map(
                (contact) => _buildContactItem(context, contact),
              ),
            ],
          ],
        ),

        // 右侧索引栏
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 24.w,
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  indexList.map((letter) {
                    return GestureDetector(
                      onTap: () {
                        // 点击字母时，滚动到对应的分组
                        Scrollable.ensureVisible(
                          letterKeys[letter]!.currentContext!,
                          duration: const Duration(milliseconds: 300),
                          alignment: 0.0,
                        );
                      },
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, Map<String, dynamic> contact) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        try {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailPage(chatId: contact['id']),
            ),
          );
        } catch (e) {
          print('导航到聊天页面失败: $e');
          try {
            context.go('/message/chat/${contact['id']}');
          } catch (e) {
            print('go_router导航失败: $e');
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                AppAvatar(
                  imageUrl: contact['avatar'],
                  size: 50,
                  placeholderText: contact['name'][0],
                  borderWidth: 0,
                ),
                // 在线状态指示器
                if (contact['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.r),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 16.w),

            // 联系人信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    contact['title'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    final theme = Theme.of(context);

    List<Map<String, dynamic>> messages = [
      {
        'id': '1',
        'name': 'Miller',
        'title': 'Product Manager',
        'avatar': 'https://i.pravatar.cc/300?img=1',
        'lastMessage': 'Hi Mariam, I\'m looking to this....',
        'time': '10:00AM',
        'status': 'unread',
        'statusColor': AppTheme.primaryColor,
        'isOnline': true,
      },
      {
        'id': '2',
        'name': 'Yevhen',
        'title': 'Senior UI UX Designer',
        'avatar': 'https://i.pravatar.cc/300?img=2',
        'lastMessage': 'Hi Mariam, I\'m looking to this....',
        'time': '10:00AM',
        'status': 'unread',
        'statusColor': AppTheme.primaryColor,
        'isOnline': true,
      },
      {
        'id': '3',
        'name': 'Ei Maulina',
        'title': 'System Analyst',
        'avatar': 'https://i.pravatar.cc/300?img=3',
        'lastMessage': 'Do you remmber me?',
        'time': '10:00AM',
        'status': 'read',
        'statusColor': AppTheme.primaryColor,
        'isOnline': false,
      },
      {
        'id': '4',
        'name': 'Bustos',
        'title': 'Junior UI UX Designer',
        'avatar': 'https://i.pravatar.cc/300?img=4',
        'lastMessage': 'Hat sounds great! What are the key....',
        'time': '10:00AM',
        'status': 'read',
        'statusColor': AppTheme.primaryColor,
        'isOnline': true,
      },
      {
        'id': '5',
        'name': 'Achmad',
        'title': 'Product Designer',
        'avatar': 'https://i.pravatar.cc/300?img=5',
        'lastMessage': 'Good morning Maria....',
        'time': '10:00AM',
        'status': 'read',
        'statusColor': AppTheme.primaryColor,
        'isOnline': false,
      },
      {
        'id': '6',
        'name': 'Nagano',
        'title': 'Data Analyst',
        'avatar': 'https://i.pravatar.cc/300?img=6',
        'lastMessage': 'Hi Mariam, I\'m looking to this....',
        'time': '10:00AM',
        'status': 'unread',
        'statusColor': AppTheme.primaryColor,
        'isOnline': true,
      },
    ];

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              '暂无聊天记录',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('新建聊天功能即将上线')));
              },
              icon: Icon(Icons.add),
              label: Text('开始聊天'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 8.h),
      itemCount: messages.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            indent: 80.w,
            endIndent: 0,
            color: theme.dividerColor.withOpacity(0.15),
          ),
      itemBuilder: (context, index) {
        final message = messages[index];
        final bool isRead = message['status'] == 'read';

        return InkWell(
          onTap: () {
            try {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(chatId: message['id']),
                ),
              );
            } catch (e) {
              print('直接导航到聊天页面失败: $e');

              try {
                context.go('/message/chat/${message['id']}');
              } catch (e) {
                print('go_router导航到聊天页面失败: $e');
              }
            }
          },
          child: Container(
            color: isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Row(
              children: [
                // 头像区域
                Stack(
                  children: [
                    AppAvatar(
                      imageUrl: message['avatar'],
                      size: 54,
                      placeholderText: message['name'][0],
                      borderWidth: 0,
                      useShimmer: true,
                      maxRetries: 3,
                    ),
                    // 在线状态指示器
                    if (message['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.r),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 16.w),

                // 消息内容区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 第一行：名称和时间
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            message['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            message['time'],
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // 第二行：职位标题
                      Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: message['statusColor'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            message['title'],
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // 第三行：消息预览
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              message['lastMessage'],
                              style: TextStyle(
                                color:
                                    isRead
                                        ? theme.textTheme.bodySmall?.color
                                        : theme.textTheme.bodyLarge?.color,
                                fontSize: 14.sp,
                                fontWeight:
                                    isRead
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 消息状态图标
                          if (!isRead)
                            Container(
                              width: 10.r,
                              height: 10.r,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            Icon(
                              Icons.done_all,
                              color: Colors.grey,
                              size: 16.r,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
