import 'message.dart';
import 'user.dart';

class Conversation {
  final Message message;
  final User user;

  Conversation({required this.message, required this.user});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      message: Message.fromJson(json['message']),
      user: User.fromJson(json['user']),
    );
  }
}
