import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  User? _user;
  bool _isAuthenticated = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _persistToken(String token, String userData) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_data', value: userData);
    _token = token;
    _user = User.fromJson(jsonDecode(userData));
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    final userData = await _storage.read(key: 'user_data');

    if (token == null || userData == null) {
      return false;
    }

    try {
      _token = token;
      _user = User.fromJson(jsonDecode(userData));
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('access_token') &&
            responseData.containsKey('user')) {
          final user = responseData['user'];
          final userId = user['id'];
          final otpEnabled = user['is_google_auth_enabled'] ?? false;

          await _persistToken(responseData['access_token'], jsonEncode(user));

          return {
            'success': true,
            'user_id': userId,
            'otp_enabled': otpEnabled,
          };
        } else {
          return {'success': false, 'message': 'Invalid response from server.'};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Login failed',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Unexpected error format from server.',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    final url = Uri.parse('$baseUrl/api/register');
    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'role_id': roleId.toString(),
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful! Please login.',
        };
      } else {
        String errorMessage = 'Registration failed.';
        if (responseData['errors'] != null) {
          errorMessage = responseData['errors'].values.first[0];
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please check your connection.',
      };
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/api/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Logout failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _token = null;
    _user = null;
    _isAuthenticated = false;
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/profile/change-password');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
      body: {'current_password': currentPassword, 'new_password': newPassword},
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['message']};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? bio,
    File? profilePicture,
  }) async {
    final url = Uri.parse('$baseUrl/api/update-profile');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_token';

    request.fields['name'] = name;
    if (bio != null) request.fields['bio'] = bio;

    if (profilePicture != null) {
      final mimeType = 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _user = User.fromJson(body['user']);
        notifyListeners();
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
