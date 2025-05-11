// lib/presentation/blocs/chat/chat_state.dart
// import 'package:equatable/equatable.dart'; // Remove this import

part of 'chat_bloc.dart';

// Represents a single chat message
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isMe;
  final String time; // Consider using DateTime for more robust time handling

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.time,
  });

  @override
  List<Object?> get props => [id, content, isMe, time];
}

// Represents the chat partner information
class ChatPartner extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;

  const ChatPartner({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final ChatPartner? partner;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.partner,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    ChatPartner? partner,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      partner: partner ?? this.partner,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, partner, errorMessage];
}
