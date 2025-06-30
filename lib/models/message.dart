import 'user.dart'; // Pastikan model User sudah sesuai revisi terbaru

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String? body;
  final String? image;
  final bool isRead;
  final DateTime createdAt;
  final User? otherUser;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.body,
    this.image,
    required this.isRead,
    required this.createdAt,
    this.otherUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image_url']?.toString().trim();

    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      body: json['body'],
      image: (rawImage != null && rawImage.isNotEmpty) ? rawImage : null,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      otherUser: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
