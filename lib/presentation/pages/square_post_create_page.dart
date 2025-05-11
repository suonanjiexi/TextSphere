import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/widgets/animated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SquarePostCreatePage extends StatefulWidget {
  const SquarePostCreatePage({Key? key}) : super(key: key);

  @override
  State<SquarePostCreatePage> createState() => _SquarePostCreatePageState();
}

class _SquarePostCreatePageState extends State<SquarePostCreatePage> {
  final TextEditingController _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          if (_selectedImages.length + pickedImages.length <= 9) {
            _selectedImages.addAll(pickedImages);
          } else {
            // 如果选择的图片超过9张，只取前9张
            final int remaining = 9 - _selectedImages.length;
            if (remaining > 0) {
              _selectedImages.addAll(pickedImages.take(remaining));
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('最多只能选择9张图片')));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() async {
    // 验证输入
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请输入内容')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 这里应该实现帖子发布逻辑，例如调用API等
    // 模拟发布延迟
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    // 发布成功后返回
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发布成功')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '发布广场',
          style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: AnimatedButton(
              onPressed: _isSubmitting ? () {} : _submitPost,
              isLoading: _isSubmitting,
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              borderRadius: 20,
              child: Text('发布'),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 内容输入区域
              TextField(
                controller: _contentController,
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: '分享你的想法...',
                  hintStyle: AppTheme.bodyMedium.copyWith(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTheme.bodyLarge,
              ),
              SizedBox(height: 16.h),

              // 已选图片预览
              if (_selectedImages.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: DecorationImage(
                              image: FileImage(
                                File(_selectedImages[index].path),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4.r,
                          right: 4.r,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],

              // 操作区域
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          _selectedImages.length < 9 ? _pickImages : null,
                      icon: Icon(
                        Icons.image_outlined,
                        color:
                            _selectedImages.length < 9
                                ? AppTheme.primaryColor
                                : Colors.grey,
                        size: 24.r,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // 功能暂未实现
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('此功能暂未实现')));
                      },
                      icon: Icon(
                        Icons.tag_outlined,
                        color: AppTheme.primaryColor,
                        size: 24.r,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // 功能暂未实现
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('此功能暂未实现')));
                      },
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.primaryColor,
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
