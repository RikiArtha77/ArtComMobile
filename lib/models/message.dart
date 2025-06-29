class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? receiverName;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.receiverName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      body: json['body'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender'] != null ? json['sender']['name'] : null,
      receiverName: json['receiver'] != null ? json['receiver']['name'] : null,
    );
  }
}
