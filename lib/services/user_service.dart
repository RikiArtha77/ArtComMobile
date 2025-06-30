import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/user.dart';

class UserService {
  final String token;

  UserService(this.token);

  Future<List<User>> searchUsers(String query) async {
    final uri = Uri.parse('$baseUrl/api/search-users?query=$query');

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Jika respons array langsung (tanpa 'users' wrapper)
      if (data is List) {
        return data.map((e) => User.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      print('Search failed with status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to search users');
    }
  }
}
