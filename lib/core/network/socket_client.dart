import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Socket客户端
///
/// 处理与后端实时通信
class SocketClient {
  /// Socket实例
  io.Socket? _socket;

  /// 是否已连接
  bool get isConnected => _socket?.connected ?? false;

  final SharedPreferences _prefs;

  /// 构造函数
  SocketClient(this._prefs);

  /// 连接服务器
  ///
  /// 参数:
  /// - [onConnect]: 连接成功回调
  /// - [onDisconnect]: 断开连接回调
  /// - [onError]: 错误回调
  /// - [onReconnect]: 重连回调
  void connect({
    Function? onConnect,
    Function? onDisconnect,
    Function? onError,
    Function? onReconnect,
  }) {
    final socketUrl = dotenv.get(
      'SOCKET_URL',
      fallback: 'http://localhost:3000',
    );
    final token = _prefs.getString('auth_token');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    // 设置事件处理
    _socket!.onConnect((_) {
      print('Socket连接成功');
      if (onConnect != null) onConnect();
    });

    _socket!.onDisconnect((_) {
      print('Socket断开连接');
      if (onDisconnect != null) onDisconnect();
    });

    _socket!.onError((error) {
      print('Socket错误: $error');
      if (onError != null) onError(error);
    });

    _socket!.onReconnect((_) {
      print('Socket重新连接');
      if (onReconnect != null) onReconnect();
    });

    // 连接服务器
    _socket!.connect();
  }

  /// 断开连接
  void disconnect() {
    _socket?.disconnect();
  }

  /// 订阅事件
  ///
  /// 参数:
  /// - [event]: 事件名称
  /// - [handler]: 事件处理函数
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// 取消订阅事件
  ///
  /// 参数:
  /// - [event]: 事件名称
  void off(String event) {
    _socket?.off(event);
  }

  /// 发送事件
  ///
  /// 参数:
  /// - [event]: 事件名称
  /// - [data]: 事件数据
  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket!.emit(event, jsonEncode(data));
    } else {
      print('Socket未连接，无法发送事件');
    }
  }

  /// 加入房间
  ///
  /// 参数:
  /// - [room]: 房间名称
  void joinRoom(String room) {
    emit('join_room', {'room': room});
  }

  /// 离开房间
  ///
  /// 参数:
  /// - [room]: 房间名称
  void leaveRoom(String room) {
    emit('leave_room', {'room': room});
  }
}
