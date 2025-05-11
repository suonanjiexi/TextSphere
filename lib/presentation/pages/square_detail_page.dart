import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:like_button/like_button.dart';
import 'package:text_sphere_app/domain/entities/comment.dart';
import 'package:text_sphere_app/presentation/blocs/post_detail/post_detail_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/post_detail/post_detail_event.dart';
import 'package:text_sphere_app/presentation/blocs/post_detail/post_detail_state.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';
import 'package:text_sphere_app/presentation/widgets/error_view.dart';
import 'dart:math' as math;
import 'package:text_sphere_app/utils/performance_utils.dart';

class SquareDetailPage extends StatefulWidget {
  final String postId;
  final PostDetailBloc postDetailBloc;

  const SquareDetailPage({
    Key? key,
    required this.postId,
    required this.postDetailBloc,
  }) : super(key: key);

  @override
  State<SquareDetailPage> createState() => _SquareDetailPageState();
}

class _SquareDetailPageState extends State<SquareDetailPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey<FormState> _commentSectionKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PostDetailBloc _postDetailBloc;

  // 将图片URL转换为Lorem Picsum格式的URL
  String _transformToLoremPicsum(
    String originalUrl, {
    int width = 800,
    int height = 600,
  }) {
    // 使用原始URL生成一个确定性的种子，使相同的URL始终生成相同的图片
    final int seed = originalUrl.hashCode.abs() % 1000;

    // 确保尺寸至少为100
    width = math.max(width, 100);
    height = math.max(height, 100);

    // 构造Lorem Picsum URL，添加图片ID（使用种子）和尺寸
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  @override
  void initState() {
    super.initState();
    _postDetailBloc = widget.postDetailBloc;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 添加整个页面的手势检测，点击空白处时取消焦点
      onTap: () {
        // 主动取消焦点，确保光标不再显示
        if (_commentFocusNode.hasFocus) {
          _commentFocusNode.unfocus();
        }
      },
      // 确保GestureDetector可以接收全屏幕的点击事件
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: StreamBuilder<PostDetailState>(
          stream: _postDetailBloc.stream,
          initialData: _postDetailBloc.state,
          builder: (context, snapshot) {
            final state = snapshot.data!;

            // 处理状态变化
            if (state is PostDeleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('帖子已删除'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
                context.pop();
              });
            }

            if (state is PostDetailLoading) {
              return Center(child: LoadingIndicator());
            }

            if (state is PostDetailError) {
              return ErrorView(
                message: '加载失败: ${state.message}',
                onRetry: () {
                  _postDetailBloc.add(LoadPostDetail(widget.postId));
                },
              );
            }

            if (state is PostDetailLoaded) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Expanded(child: _buildScrollView(state)),
                    _buildCommentInput(context, state),
                  ],
                ),
              );
            }

            return Center(child: Text('未找到帖子'));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 22.sp, color: Colors.black87),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: Text(
        '帖子详情',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        StreamBuilder<PostDetailState>(
          stream: _postDetailBloc.stream,
          initialData: _postDetailBloc.state,
          builder: (context, snapshot) {
            final state = snapshot.data!;
            if (state is PostDetailLoaded) {
              return IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  size: 22.sp,
                  color: Colors.black87,
                ),
                onPressed: () {
                  _showPostOptions(context, state);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildScrollView(PostDetailLoaded state) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildPostContent(context, state),
                SizedBox(height: 20.h),
                _buildCommentSection(context, state),
                SizedBox(height: 80.h), // 从100.h减少到80.h，让输入框不至于太靠下
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(BuildContext context, PostDetailLoaded state) {
    final post = state.post;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 跳转到用户资料页
                  context.push('/profile/${post.userId}');
                },
                child: Hero(
                  tag: 'avatar-${post.userId}',
                  child: CircleAvatar(
                    radius: 25.r,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        post.userAvatar != null && post.userAvatar.isNotEmpty
                            ? CachedNetworkImageProvider(post.userAvatar)
                            : null,
                    child:
                        post.userAvatar == null || post.userAvatar.isEmpty
                            ? Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 30.r,
                            )
                            : null,
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.username,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Lv.${(post.username.hashCode % 10) + 1}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDateTime(post.createdAt),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: () {
                    _postDetailBloc.add(ToggleFollowAuthor());
                    HapticFeedback.lightImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        state.isFollowingAuthor
                            ? Colors.grey[200]
                            : Theme.of(context).primaryColor,
                    foregroundColor:
                        state.isFollowingAuthor
                            ? Colors.grey[700]
                            : Colors.white,
                    elevation: state.isFollowingAuthor ? 0 : 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isFollowingAuthor ? Icons.check : Icons.add,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        state.isFollowingAuthor ? '已关注' : '关注',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // 帖子标题
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // 帖子内容
          Text(
            post.content,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.6,
              color: Colors.black.withOpacity(0.8),
            ),
          ),

          SizedBox(height: 15.h),

          // 图片
          if (post.images != null &&
              post.images.isNotEmpty &&
              post.images.length > 1) ...[
            _buildImages(post.images),
            SizedBox(height: 15.h),
          ],

          // 标签
          if (post.topics != null && post.topics.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  post.topics.map<Widget>((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Color(0xFFE5E6EB), width: 1),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            SizedBox(height: 15.h),
          ],

          // 帖子行为
          Divider(color: Colors.grey[200]),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLikeButton(
                post.isLiked,
                post.likeCount,
                () => _postDetailBloc.add(ToggleLike()),
              ),
              _buildActionButton(
                Icons.comment_outlined,
                Colors.grey[600],
                '${post.commentCount}',
                () {
                  // 滚动到评论区
                  Scrollable.ensureVisible(
                    _commentSectionKey.currentContext!,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              _buildActionButton(
                Icons.share_outlined,
                Colors.grey[600],
                '分享',
                () {
                  _showShareOptions();
                  HapticFeedback.mediumImpact();
                },
              ),
              _buildCollectButton(
                state.isCollected,
                () => _postDetailBloc.add(ToggleCollect()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(bool isLiked, int count, VoidCallback onTap) {
    return LikeButton(
      size: 24.sp,
      isLiked: isLiked,
      likeCount: count,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.grey[600],
          size: 22.sp,
        );
      },
      likeCountAnimationType: LikeCountAnimationType.all,
      countBuilder: (int? count, bool isLiked, String text) {
        return Text(
          text,
          style: TextStyle(
            color: isLiked ? Colors.red : Colors.grey[600],
            fontSize: 14.sp,
          ),
        );
      },
      onTap: (isLiked) async {
        onTap();
        HapticFeedback.lightImpact();
        return !isLiked;
      },
    );
  }

  Widget _buildCollectButton(bool isCollected, VoidCallback onTap) {
    return LikeButton(
      size: 24.sp,
      isLiked: isCollected,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.bookmark : Icons.bookmark_border,
          color: isLiked ? Theme.of(context).primaryColor : Colors.grey[600],
          size: 22.sp,
        );
      },
      countBuilder: (int? count, bool isLiked, String text) {
        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            '收藏',
            style: TextStyle(
              color:
                  isLiked ? Theme.of(context).primaryColor : Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
        );
      },
      onTap: (isLiked) async {
        onTap();
        HapticFeedback.lightImpact();
        return !isLiked;
      },
    );
  }

  Widget _buildImages(List<String> images) {
    if (images.length == 1) {
      return GestureDetector(
        onTap: () => _showImageViewer(images, 0),
        child: Hero(
          tag: 'image-${images[0]}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: _transformToLoremPicsum(
                images[0],
                width: 800,
                height: 500,
              ),
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 600,
              filterQuality: PerformanceUtils.getOptimalFilterQuality(),
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error),
                  ),
            ),
          ),
        ),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.w,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageViewer(images, index),
            child: Hero(
              tag: 'image-${images[index]}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: _transformToLoremPicsum(
                    images[index],
                    width: 300,
                    height: 300,
                  ),
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  memCacheHeight: 600,
                  filterQuality: PerformanceUtils.getOptimalFilterQuality(),
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showImageViewer(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _FullScreenImageViewer(
              images:
                  images
                      .map(
                        (url) => _transformToLoremPicsum(
                          url,
                          width: 1200,
                          height: 800,
                        ),
                      )
                      .toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, PostDetailLoaded state) {
    final isAuthor = state.isAuthor;
    final postId = state.post.id;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '更多操作',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              if (isAuthor) ...[
                _buildActionItem(
                  icon: Icons.edit,
                  title: '编辑帖子',
                  onTap: () {
                    Navigator.pop(context);
                    // 跳转到编辑帖子页面
                    context.push('/edit-post/$postId');
                  },
                ),
                _buildActionItem(
                  icon: Icons.delete,
                  title: '删除帖子',
                  destructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('确认删除'),
                            content: Text('你确定要删除这篇帖子吗？此操作无法撤销。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('确认'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true && context.mounted) {
                      _postDetailBloc.add(DeletePost());
                    }
                  },
                ),
              ] else ...[
                _buildActionItem(
                  icon: Icons.report,
                  title: '举报帖子',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('举报已提交')));
                  },
                ),
              ],
              _buildActionItem(
                icon: Icons.content_copy,
                title: '复制链接',
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(
                    ClipboardData(text: 'https://yourdomain.com/post/$postId'),
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('链接已复制')));
                },
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '分享到',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareItem(
                    icon: Icons.chat,
                    title: '微信',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('分享到微信')));
                    },
                  ),
                  _buildShareItem(
                    icon: Icons.message,
                    title: '短信',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('分享到短信')));
                    },
                  ),
                  _buildShareItem(
                    icon: Icons.more_horiz,
                    title: '更多',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('更多分享选项')));
                    },
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: Color(0xFFF6F7F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: destructive ? Colors.red : Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: destructive ? Colors.red : Colors.black87),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCommentSection(BuildContext context, PostDetailLoaded state) {
    return Container(
      key: _commentSectionKey,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '评论 (${state.comments.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          if (state.isLoadingComments)
            Center(child: LoadingIndicator())
          else if (state.comments.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Text(
                  '暂无评论，来发表第一条评论吧',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...state.comments
                .map((comment) => _buildCommentItem(context, comment, state))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    Comment comment,
    PostDetailLoaded state,
  ) {
    final bool hasReply = comment.isReply;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.push('/profile/${comment.userId}');
              },
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    comment.userAvatar != null && comment.userAvatar.isNotEmpty
                        ? CachedNetworkImageProvider(comment.userAvatar)
                        : null,
                child:
                    comment.userAvatar == null || comment.userAvatar.isEmpty
                        ? Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 18.r,
                        )
                        : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    comment.content,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        _formatDateTime(comment.createdAt),
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          _postDetailBloc.add(ToggleLikeComment(comment.id));
                        },
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 14.sp,
                              color: comment.isLiked ? Colors.red : Colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: () {
                          _replyToComment(context, comment);
                        },
                        child: Icon(
                          Icons.reply,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        if (hasReply && comment.replyToUsername != null) ...[
          SizedBox(height: 10.h),
          Container(
            margin: EdgeInsets.only(left: 40.w),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: comment.replyToUsername,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(text: '：回复内容'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 15.h),
        if (state.comments.isNotEmpty && state.comments.last.id != comment.id)
          Divider(color: Colors.grey[200]),
        SizedBox(height: 15.h),
      ],
    );
  }

  void _replyToComment(BuildContext context, Comment comment) {
    _postDetailBloc.add(SetReplyTo(comment));
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(Duration(milliseconds: 50), () {
      FocusScope.of(context).requestFocus(_commentFocusNode);
    });
  }

  Widget _buildCommentInput(BuildContext context, PostDetailLoaded state) {
    final String hintText =
        state.replyTo == null
            ? '写下你的评论...'
            : '回复 ${state.replyTo!.username}...';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 15.h,
      ), // 增加垂直内边距
      margin: EdgeInsets.only(bottom: 15.h), // 添加底部外边距，让输入框距离底部更远
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.replyTo != null)
            Row(
              children: [
                Text(
                  '回复: ${state.replyTo!.username}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () => _postDetailBloc.add(ClearReplyTo()),
                  child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          SizedBox(height: state.replyTo != null ? 8.h : 0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _postDetailBloc.add(SetCommentText(value));
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _submitComment(context);
                    }
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      _submitComment(context);
                    }
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(BuildContext context) {
    _postDetailBloc.add(SubmitComment());
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Widget _buildActionButton(
    IconData icon,
    Color? color,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 全屏图片查看器
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late int _currentIndex;
  late PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 自动隐藏控件
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      // 如果显示了控件，3秒后自动隐藏
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    widget.images[index],
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'image-${widget.images[index]}',
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                            size: 50.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '图片加载失败',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              itemCount: widget.images.length,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundDecoration: BoxDecoration(color: Colors.black),
              loadingBuilder:
                  (context, event) => Center(
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value:
                                event == null
                                    ? 0
                                    : event.cumulativeBytesLoaded /
                                        (event.expectedTotalBytes ?? 1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          if (event != null &&
                              event.expectedTotalBytes != null) ...[
                            SizedBox(height: 10.h),
                            Text(
                              '${((event.cumulativeBytesLoaded / event.expectedTotalBytes!) * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          '${_currentIndex + 1}/${widget.images.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('分享图片')));
                          },
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.save_alt, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('保存图片')));
                            },
                          ),
                          SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('编辑图片')));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
