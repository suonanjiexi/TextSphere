import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/domain/entities/circle_post.dart';
import 'package:text_sphere_app/domain/entities/comment.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late CirclePost _post;
  late List<Comment> _comments;
  bool _isLoading = true;
  String? _replyingTo;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟帖子数据
    _post = CirclePost(
      id: widget.postId,
      circleId: 'circle1',
      title: 'Flutter 3.0 新特性解析',
      content:
          '这是一篇详细介绍Flutter 3.0新特性的帖子，Flutter 3.0带来了许多激动人心的改进，包括但不限于：\n\n'
          '1. 更好的性能优化\n'
          '2. 新增Material 3设计风格支持\n'
          '3. iOS改进\n'
          '4. 更好的可访问性支持\n\n'
          '接下来我们将详细探讨这些新特性对开发者的影响和如何在项目中应用这些特性。',
      imageUrls: [
        'https://picsum.photos/seed/post1/400/300',
        'https://picsum.photos/seed/post2/400/300',
      ],
      authorId: 'user1',
      authorName: '张三',
      authorAvatar: 'https://i.pravatar.cc/150?u=user1',
      createdAt: '2天前',
      likesCount: 42,
      commentsCount: 18,
      viewsCount: 108,
      isLiked: false,
      isPinned: true,
      isEssence: true,
    );

    // 模拟评论数据
    _comments = [
      Comment(
        id: 'comment1',
        postId: widget.postId,
        userId: 'user2',
        username: '李四',
        userAvatar: 'https://i.pravatar.cc/150?u=user2',
        content: '这篇文章太棒了，对我帮助很大！',
        likeCount: 5,
        replyCount: 2,
        isLiked: true,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        replies: [
          Comment(
            id: 'reply1',
            postId: widget.postId,
            userId: 'user3',
            username: '王五',
            userAvatar: 'https://i.pravatar.cc/150?u=user3',
            content: '是的，我也这么认为。',
            parentId: 'comment1',
            replyToUserId: 'user2',
            replyToUsername: '李四',
            likeCount: 2,
            replyCount: 0,
            isLiked: false,
            createdAt: DateTime.now().subtract(Duration(hours: 2)),
          ),
          Comment(
            id: 'reply2',
            postId: widget.postId,
            userId: 'user1',
            username: '张三',
            userAvatar: 'https://i.pravatar.cc/150?u=user1',
            content: '谢谢支持！',
            parentId: 'comment1',
            replyToUserId: 'user2',
            replyToUsername: '李四',
            likeCount: 1,
            replyCount: 0,
            isLiked: false,
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
          ),
        ],
      ),
      Comment(
        id: 'comment2',
        postId: widget.postId,
        userId: 'user4',
        username: '赵六',
        userAvatar: 'https://i.pravatar.cc/150?u=user4',
        content: '我有一个问题，Flutter 3.0的性能优化具体体现在哪些方面？',
        likeCount: 3,
        replyCount: 1,
        isLiked: false,
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
        replies: [
          Comment(
            id: 'reply3',
            postId: widget.postId,
            userId: 'user1',
            username: '张三',
            userAvatar: 'https://i.pravatar.cc/150?u=user1',
            content: '主要体现在渲染速度和内存占用方面，相比之前版本有约20%的性能提升。',
            parentId: 'comment2',
            replyToUserId: 'user4',
            replyToUsername: '赵六',
            likeCount: 4,
            replyCount: 0,
            isLiked: true,
            createdAt: DateTime.now().subtract(Duration(hours: 4)),
          ),
        ],
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: LoadingIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('帖子详情'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showPostOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 帖子内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostHeader(),
                  SizedBox(height: 16.h),
                  _buildPostContent(),
                  SizedBox(height: 16.h),
                  _buildPostImages(),
                  SizedBox(height: 16.h),
                  _buildPostStats(),
                  Divider(height: 24.h),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          // 评论输入区域
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: _post.authorAvatar,
          size: 48,
          placeholderText: _post.authorName,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post.authorName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _post.createdAt,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _post.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Text(
      _post.content,
      style: TextStyle(
        fontSize: 16.sp,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      ),
    );
  }

  Widget _buildPostImages() {
    if (_post.imageUrls.isEmpty) {
      return SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _post.imageUrls.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: AppNetworkImage(
              imageUrl: _post.imageUrls[index],
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostStats() {
    return Row(
      children: [
        _buildActionButton(
          icon: _post.isLiked ? Icons.favorite : Icons.favorite_border,
          label: '${_post.likesCount}',
          color: _post.isLiked ? Colors.red : null,
          onTap: () {
            setState(() {
              _post = _post.copyWith(
                isLiked: !_post.isLiked,
                likesCount:
                    _post.isLiked ? _post.likesCount - 1 : _post.likesCount + 1,
              );
            });
          },
        ),
        SizedBox(width: 24.w),
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: '${_post.commentsCount}',
          onTap: () {
            _commentFocusNode.requestFocus();
          },
        ),
        SizedBox(width: 24.w),
        _buildActionButton(
          icon: Icons.remove_red_eye_outlined,
          label: '${_post.viewsCount}',
          onTap: null,
        ),
        Spacer(),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: '分享',
          onTap: () {
            // 分享帖子
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.r,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '评论 (${_post.commentsCount})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            return _buildCommentItem(_comments[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主评论
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(
              imageUrl: comment.userAvatar,
              size: 36,
              placeholderText: comment.username,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${comment.createdAt.difference(DateTime.now()).inHours.abs()}小时前',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            comment = comment.copyWith(
                              isLiked: !comment.isLiked,
                              likeCount:
                                  comment.isLiked
                                      ? comment.likeCount - 1
                                      : comment.likeCount + 1,
                            );
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16.r,
                              color:
                                  comment.isLiked
                                      ? Colors.red
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {
                          _setReplyingTo(comment.id, comment.username);
                        },
                        child: Text(
                          '回复',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.primary,
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

        // 回复列表
        if (comment.hasReplies)
          Padding(
            padding: EdgeInsets.only(left: 48.w, top: 12.h),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comment.replies.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildReplyItem(comment.replies[index], comment.id);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(Comment reply, String parentId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: reply.userAvatar,
          size: 32,
          placeholderText: reply.username,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reply.username,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  children: [
                    if (reply.replyToUserId != null)
                      TextSpan(
                        text: '回复 ${reply.replyToUsername}: ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    TextSpan(
                      text: reply.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    '${reply.createdAt.difference(DateTime.now()).inHours.abs()}小时前',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        reply = reply.copyWith(
                          isLiked: !reply.isLiked,
                          likeCount:
                              reply.isLiked
                                  ? reply.likeCount - 1
                                  : reply.likeCount + 1,
                        );
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          reply.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14.r,
                          color:
                              reply.isLiked
                                  ? Colors.red
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${reply.likeCount}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () {
                      _setReplyingTo(parentId, reply.username);
                    },
                    child: Text(
                      '回复',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replyingTo != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text(
                      '回复: $_replyingTo',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingTo = null;
                        });
                      },
                      child: Icon(
                        Icons.cancel,
                        size: 16.r,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        hintText: '添加评论...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    _submitComment();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setReplyingTo(String commentId, String username) {
    setState(() {
      _replyingTo = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _submitComment() {
    if (_commentController.text.isEmpty) return;

    // 添加新评论逻辑
    setState(() {
      if (_replyingTo == null) {
        // 添加主评论
        _comments.add(
          Comment(
            id: 'comment${_comments.length + 1}',
            postId: widget.postId,
            userId: 'currentUser',
            username: '当前用户',
            userAvatar: 'https://i.pravatar.cc/150?u=currentUser',
            content: _commentController.text,
            likeCount: 0,
            replyCount: 0,
            isLiked: false,
            createdAt: DateTime.now(),
          ),
        );
        _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
      } else {
        // 添加回复
        // 实际应用中应该更新对应的评论
        // 这里简化为添加到第一条评论
        _comments[0] = _comments[0].copyWith(
          replies: [
            ..._comments[0].replies,
            Comment(
              id: 'reply${_comments[0].replies.length + 1}',
              postId: widget.postId,
              userId: 'currentUser',
              username: '当前用户',
              userAvatar: 'https://i.pravatar.cc/150?u=currentUser',
              content: _commentController.text,
              parentId: _comments[0].id,
              replyToUserId: _comments[0].userId,
              replyToUsername: _replyingTo,
              likeCount: 0,
              replyCount: 0,
              isLiked: false,
              createdAt: DateTime.now(),
            ),
          ],
          replyCount: _comments[0].replyCount + 1,
        );
        _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
      }

      _commentController.clear();
      _replyingTo = null;
    });
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share),
                title: Text('分享帖子'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享帖子
                },
              ),
              ListTile(
                leading: Icon(Icons.bookmark_border),
                title: Text('收藏帖子'),
                onTap: () {
                  Navigator.pop(context);
                  // 收藏帖子
                },
              ),
              ListTile(
                leading: Icon(Icons.flag_outlined),
                title: Text('举报'),
                onTap: () {
                  Navigator.pop(context);
                  // 举报帖子
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
