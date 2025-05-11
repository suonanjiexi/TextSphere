// lib/presentation/blocs/chat/chat_event.dart
// import 'package:equatable/equatable.dart'; // Remove this import

part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// Event to load initial chat data
class LoadChat extends ChatEvent {
  final String chatId;

  const LoadChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

// Event when a new message is sent by the user
class SendMessage extends ChatEvent {
  final String text;

  const SendMessage(this.text);

  @override
  List<Object?> get props => [text];
}

// Event triggered internally when a message is received (e.g., from partner or backend)
class _MessageReceived extends ChatEvent {
  final ChatMessage message;

  const _MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
