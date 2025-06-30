import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user.dart';
import '../models/post.dart'; // Harus sesuai model artwork-mu

class UserService {
  final String token;

  UserService(this.token);

  /// Cari pengguna berdasarkan nama
  Future<List<User>> searchUsers(String query) async {
    final uri = Uri.parse('$baseUrl/api/search-users?query=$query');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((e) => User.fromJson(e)).toList();
      } else {
        throw Exception('Format respons tidak sesuai');
      }
    } else {
      print('Search failed with status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Gagal mencari pengguna');
    }
  }

  /// Ambil karya (artworks) yang diupload oleh user tertentu
  Future<List<Post>> getUserPosts(int userId) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/artworks');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Format respons tidak sesuai untuk artworks');
      }
    } else {
      print('Get artworks failed with status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Gagal mengambil karya pengguna');
    }
  }
}
