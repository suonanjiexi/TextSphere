import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_event.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  /// 登录成功后的重定向路径
  final String? redirectAfterLogin;

  const LoginPage({Key? key, this.redirectAfterLogin}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('登录'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),
              // 标题
              Text(
                '欢迎回来',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                '请登录您的账号',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 32.h),

              // 用户名输入框
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '用户名',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // 密码输入框
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.h),

              // 忘记密码
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: 实现忘记密码功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('忘记密码功能正在开发中')),
                    );
                  },
                  child: const Text('忘记密码？'),
                ),
              ),
              SizedBox(height: 24.h),

              // 登录按钮
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('登录', style: TextStyle(fontSize: 16.sp)),
              ),
              SizedBox(height: 16.h),

              // 注册链接
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '还没有账号？',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 跳转到注册页面
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('注册功能正在开发中')),
                      );
                    },
                    child: const Text('立即注册'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      // 触发登录事件
      context.read<AuthBloc>().add(
        LoginEvent(username: username, password: password),
      );

      // TODO: 处理登录成功后的重定向
      if (widget.redirectAfterLogin != null) {
        // 使用一个简单的延迟来模拟登录过程
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(
            context,
          ).pushReplacementNamed(widget.redirectAfterLogin!);
        });
      }
    }
  }
}
