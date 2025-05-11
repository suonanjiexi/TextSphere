import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 错误页面组件
///
/// 用于显示应用程序错误信息的页面
class ErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showBackButton;

  const ErrorPage({
    Key? key,
    required this.message,
    this.onRetry,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          showBackButton
              ? AppBar(
                title: Text('出错了'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
              : null,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.r, color: Colors.red[300]),
              SizedBox(height: 24.h),
              Text(
                message,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Text('重试'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
