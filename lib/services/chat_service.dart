import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatService {
  static const String baseUrl = 'http://192.168.1.14:8000/api';
  final String token;

  ChatService(this.token);

  Map<String, String> get headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  /// Ambil semua pesan dengan user tertentu
  Future<List<Message>> getMessages(int receiverId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$receiverId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body is List) {
        return body.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Format pesan tidak dikenali');
      }
    } else {
      throw Exception('Gagal mengambil pesan: ${response.statusCode}');
    }
  }

  /// Tandai pesan dari user tertentu sudah dibaca
  Future<void> markAsRead(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages/read/$userId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final body = await response.body;
      throw Exception('Gagal menandai pesan telah dibaca: $body');
    }
  }

  /// Kirim pesan teks atau gambar
  Future<void> sendMessage({
    required int receiverId,
    String? body,
    File? image,
  }) async {
    final uri = Uri.parse('$baseUrl/messages');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..fields['receiver_id'] = receiverId.toString();

    if (body != null && body.isNotEmpty) {
      request.fields['body'] = body;
    }

    if (image != null) {
      final mimeType = 'image/jpeg'; // opsional, bisa deteksi otomatis
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 201 && response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Gagal mengirim pesan: $respStr');
    }
  }

  /// Ambil semua percakapan
  Future<List<Message>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is List) {
        return body.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Format data tidak sesuai');
      }
    } else {
      throw Exception('Gagal load percakapan: ${response.statusCode}');
    }
  }
}
