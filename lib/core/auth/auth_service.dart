import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 用户登录状态
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // 用户信息
  String? _userId;
  String? get userId => _userId;
  String? _userName;
  String? get userName => _userName;

  // 初始化
  Future<void> initialize() async {
    await _loadAuthState();
  }

  // 从本地存储加载认证状态
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  // 登录
  Future<bool> login(String username, String password) async {
    // 模拟登录请求
    await Future.delayed(const Duration(seconds: 1));

    // 假设登录成功
    _isLoggedIn = true;
    _userId = '12345';
    _userName = username;

    // 保存登录状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', _userId!);
    await prefs.setString('userName', _userName!);

    notifyListeners();
    return true;
  }

  // 登出
  Future<void> logout() async {
    // 清除登录状态
    _isLoggedIn = false;
    _userId = null;
    _userName = null;

    // 清除本地存储的登录信息
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userName');

    notifyListeners();
  }
}
