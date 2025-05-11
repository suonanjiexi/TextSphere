import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/user.dart'; // Assuming User entity might be needed later

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // TODO: Inject necessary repositories (e.g., ChatRepository) later
  ChatBloc() : super(const ChatState()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<_MessageReceived>(_onMessageReceived);
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 300));

      // --- Mock Data Loading (Replace with Repository Call) ---
      ChatPartner partner;
      List<ChatMessage> messages = [];
      if (event.chatId == '1') {
        partner = const ChatPartner(
          id: '1',
          name: '前端交流',
          avatarUrl: 'https://i.pravatar.cc/150?u=1',
        );
        messages.addAll([
          const ChatMessage(
            id: 'm1',
            content: '嗨，最近怎么样？',
            isMe: false,
            time: '10:15',
          ),
          const ChatMessage(
            id: 'm2',
            content: '还不错，在忙一个新项目，你呢？',
            isMe: true,
            time: '10:16',
          ),
          const ChatMessage(
            id: 'm3',
            content: '我刚从出差回来，还在倒时差',
            isMe: false,
            time: '10:18',
          ),
          const ChatMessage(
            id: 'm4',
            content: '周末有空一起吃个饭吗？',
            isMe: false,
            time: '10:20',
          ),
          const ChatMessage(
            id: 'm5',
            content: '好啊，周六晚上怎么样？',
            isMe: true,
            time: '10:25',
          ),
          const ChatMessage(
            id: 'm6',
            content: '没问题，老地方见！',
            isMe: false,
            time: '10:30',
          ),
        ]);
      } else {
        partner = ChatPartner(
          id: event.chatId,
          name: '消息 ${event.chatId}',
          avatarUrl: 'https://i.pravatar.cc/150?u=${event.chatId}',
        );
        messages.addAll([
          const ChatMessage(
            id: 'm1',
            content: '你好',
            isMe: false,
            time: '09:00',
          ),
          const ChatMessage(
            id: 'm2',
            content: '你好，有什么事吗？',
            isMe: true,
            time: '09:05',
          ),
        ]);
      }
      // --- End Mock Data Loading ---

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          partner: partner,
          messages: messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (event.text.trim().isEmpty || state.status != ChatStatus.loaded) return;

    final newMessage = ChatMessage(
      id: 'm${state.messages.length + 1}_${DateTime.now().millisecondsSinceEpoch}', // More unique ID
      content: event.text,
      isMe: true,
      time:
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    );

    // Add message optimistically
    emit(state.copyWith(messages: List.from(state.messages)..add(newMessage)));

    // TODO: Call repository to send message to backend/service

    // Simulate partner reply (remove in real app)
    if (state.messages.length % 4 == 0) {
      await Future.delayed(const Duration(seconds: 1));
      add(
        _MessageReceived(
          ChatMessage(
            id:
                'm${state.messages.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
            content: '收到: "${event.text}". 好的!',
            isMe: false,
            time:
                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          ),
        ),
      );
    }
  }

  void _onMessageReceived(_MessageReceived event, Emitter<ChatState> emit) {
    if (state.status != ChatStatus.loaded) return;
    emit(
      state.copyWith(messages: List.from(state.messages)..add(event.message)),
    );
  }
}
