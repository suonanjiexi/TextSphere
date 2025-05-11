import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';

/// 自定义文本输入字段
class AppTextField extends StatelessWidget {
  /// 控制器
  final TextEditingController? controller;

  /// 标签文本
  final String? labelText;

  /// 提示文本
  final String? hintText;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 是否加密文本
  final bool obscureText;

  /// 键盘类型
  final TextInputType keyboardType;

  /// 输入动作
  final TextInputAction textInputAction;

  /// 验证器
  final String? Function(String?)? validator;

  /// 启用状态
  final bool enabled;

  /// 最大行数
  final int? maxLines;

  /// 最小行数
  final int? minLines;

  /// 最大字符数
  final int? maxLength;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 内容变更回调
  final void Function(String)? onChanged;

  /// 提交回调
  final void Function(String)? onSubmitted;

  /// 构造函数
  const AppTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          style: AppTheme.bodyMedium,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, size: 22.r, color: AppTheme.textLight)
                    : null,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
