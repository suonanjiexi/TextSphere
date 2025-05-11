import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/di/injection_container.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_event.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_state.dart';

class CircleCreatePage extends StatefulWidget {
  const CircleCreatePage({Key? key}) : super(key: key);

  @override
  State<CircleCreatePage> createState() => _CircleCreatePageState();
}

class _CircleCreatePageState extends State<CircleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '科技';
  final List<String> _categories = ['科技', '生活', '文化', '教育', '娱乐', '其他'];

  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    '科技',
    '编程',
    '人工智能',
    '移动开发',
    'Flutter',
    '美食',
    '旅行',
    '摄影',
    '健康',
    '运动',
    '文学',
    '艺术',
    '电影',
    '音乐',
    '历史',
    '教育',
    '学习',
    '考试',
    '技能',
    '职场',
    '游戏',
    '动漫',
    '宠物',
    '时尚',
    '汽车',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CircleBloc>(),
      child: BlocListener<CircleBloc, CircleState>(
        listener: (context, state) {
          if (state.status == CircleStatus.loading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state.status == CircleStatus.success) {
            setState(() {
              _isLoading = false;
            });
            // 创建成功后返回
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('圈子创建成功！')));
            context.pop();
          } else if (state.status == CircleStatus.failure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('创建失败: ${state.errorMessage}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('创建圈子'),
            elevation: 0,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child:
                    _isLoading
                        ? Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        )
                        : TextButton(
                          onPressed: _submitForm,
                          child: Text(
                            '创建',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildNameField(),
          SizedBox(height: 20.h),
          _buildDescriptionField(),
          SizedBox(height: 20.h),
          _buildCategoryDropdown(),
          SizedBox(height: 20.h),
          _buildTagsSelector(),
          SizedBox(height: 30.h),
          _buildPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: '圈子名称',
        hintText: '请输入圈子名称（2-20个字符）',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '圈子名称不能为空';
        }
        if (value.trim().length < 2) {
          return '圈子名称至少需要2个字符';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: '圈子描述',
        hintText: '请简要描述圈子的内容和目标（10-200个字符）',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        alignLabelWithHint: true,
      ),
      maxLines: 5,
      maxLength: 200,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '圈子描述不能为空';
        }
        if (value.trim().length < 10) {
          return '圈子描述至少需要10个字符';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择类别',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items:
                  _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择标签（最多5个）',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedTags.length < 5) {
                          _selectedTags.add(tag);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('最多只能选择5个标签')),
                          );
                        }
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final name =
        _nameController.text.isNotEmpty ? _nameController.text : '圈子名称';
    final description =
        _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : '圈子描述内容';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '预览',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                child: Container(
                  height: 100.h,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  child: Center(
                    child: Icon(Icons.image, size: 50.r, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          radius: 20.r,
                          child: Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '类别: $_selectedCategory',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          _selectedTags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTags.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请至少选择一个标签')));
        return;
      }

      context.read<CircleBloc>().add(
        CreateCircle(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          tags: _selectedTags,
        ),
      );
    }
  }
}
