import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';

class CirclePostCreatePage extends StatefulWidget {
  final String circleId;

  const CirclePostCreatePage({Key? key, required this.circleId})
    : super(key: key);

  @override
  State<CirclePostCreatePage> createState() => _CirclePostCreatePageState();
}

class _CirclePostCreatePageState extends State<CirclePostCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<XFile> _imageFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  // 这里应该用BLoC来获取圈子信息，暂时模拟数据
  late final Circle _circle = Circle(
    id: widget.circleId,
    name: '探索Flutter圈',
    description: '这是一个讨论Flutter开发技术的圈子，欢迎各位开发者加入交流和分享经验。',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    coverUrl: 'https://picsum.photos/seed/${widget.circleId}/800/200',
    membersCount: 3258,
    postsCount: 1257,
    isJoined: true,
    category: '技术',
    tags: ['Flutter', 'Dart', '移动开发', '跨平台'],
    createdAt: '2023-01-15',
    creatorId: 'user1',
    creatorName: '张三',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '发布帖子',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publishPost,
            child: Text(
              '发布',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color:
                    _titleController.text.isNotEmpty &&
                            _contentController.text.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCircleInfo(),
                      SizedBox(height: 16.h),
                      _buildTitleInput(),
                      SizedBox(height: 16.h),
                      _buildContentInput(),
                      SizedBox(height: 16.h),
                      _buildImagePicker(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCircleInfo() {
    return Row(
      children: [
        AppAvatar(
          imageUrl: _circle.avatarUrl,
          size: 40,
          placeholderText: _circle.name[0],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _circle.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                '${_circle.membersCount}成员 · ${_circle.postsCount}帖子',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      maxLength: 50,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '标题（必填）',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 18.sp),
        border: InputBorder.none,
        counterText: '',
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 10,
      minLines: 5,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        hintText: '分享你的想法...',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
        border: InputBorder.none,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '添加图片',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 8.w,
          children: [
            ..._imageFiles.map((image) => _buildImageItem(image)),
            if (_imageFiles.length < 9) _buildAddImageButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(XFile image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(File(image.path), fit: BoxFit.cover),
        ),
        Positioned(
          top: 4.r,
          right: 4.r,
          child: GestureDetector(
            onTap:
                () => setState(() {
                  _imageFiles.remove(image);
                }),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 14.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: Colors.grey[600],
          size: 32.r,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFiles.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败：$e')));
    }
  }

  void _publishPost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请输入标题')));
      return;
    }

    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请输入内容')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 实际项目中应当使用BLoC和Repository来处理发帖逻辑
      // 这里仅作示例
      await Future.delayed(Duration(seconds: 2)); // 模拟网络请求

      if (!mounted) return;

      // 成功发帖后返回上一页
      context.pop();

      // 显示发帖成功提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发布成功')));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发布失败：$e')));
    }
  }
}
