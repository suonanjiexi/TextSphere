import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          nickname: _nicknameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _usernameController,
                    labelText: '用户名',
                    hintText: '请输入用户名',
                    validator: (v) => v?.isEmpty == true ? '请输入用户名' : null,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _nicknameController,
                    labelText: '昵称',
                    hintText: '请输入昵称',
                    validator: (v) => v?.isEmpty == true ? '请输入昵称' : null,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _passwordController,
                    labelText: '密码',
                    hintText: '请输入密码（至少6位）',
                    obscureText: _obscurePassword,
                    validator:
                        (v) => v == null || v.length < 6 ? '密码至少6位' : null,
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        text: '注册',
                        isLoading: state is AuthLoading,
                        onPressed: _submitForm,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
