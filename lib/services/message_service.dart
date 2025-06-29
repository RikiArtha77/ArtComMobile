import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final String token;

  MessageService({required this.token});

  Map<String, String> get headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  Future<List<dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversation'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }

  Future<List<Message>> getMessagesWithUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  Future<void> sendMessage({
    required int receiverId,
    required String body,
    int? artworkId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'receiver_id': receiverId,
        'body': body,
        if (artworkId != null) 'artwork_id': artworkId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }
}
