// lib/api/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/artworks.dart';
import '../models/category.dart';

class ApiService {
  /// Mengambil daftar karya seni dengan pagination dari API.
  /// Endpoint: GET /api/artworks
  static Future<Map<String, dynamic>> fetchArtworks(int page, {int pageSize = 10}) async {
    // MODIFIED: Menambahkan parameter 'limit' ke URL untuk mengontrol jumlah item per halaman.
    final url = Uri.parse('$baseUrl/api/artworks?page=$page&limit=$pageSize');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Pastikan 'data' ada dan merupakan sebuah list
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
             final List<Artwork> artworks = (jsonResponse['data'] as List)
              .map((item) => Artwork.fromJson(item, baseUrl))
              .toList();
            final isLastPage = jsonResponse['next_page_url'] == null;
            return {
              'success': true,
              'artworks': artworks,
              'isLastPage': isLastPage,
            };
        } else {
             // Handle jika 'data' tidak ada atau bukan list
            return {
              'success': false,
              'message': 'Invalid data format from server.',
            };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to load artworks. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Mengambil semua kategori dari API.
  /// Endpoint: GET /api/categories
  static Future<Map<String, dynamic>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/categories');
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final List<Category> categories =
            jsonResponse.map((cat) => Category.fromJson(cat)).toList();

        return {'success': true, 'categories': categories};
      } else {
        return {
          'success': false,
          'message': 'Failed to load categories. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  /// Mengirim karya baru ke API.
  /// Endpoint: POST /api/artworks
  static Future<Map<String, dynamic>> createArtwork({
    required int categoryId,
    required String title,
    required String description,
    required String filePath,
    required String token,
  }) async {
    try {
      print('[DEBUG] Preparing to send artwork data to server...');
      print('Title: $title, Description: $description');
      print('Category ID: $categoryId');
      print('File path: $filePath');

      final uri = Uri.parse('$baseUrl/api/artworks');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['category_id'] = categoryId.toString()
        ..fields['title'] = title
        ..fields['description'] = description
        ..files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[DEBUG] Server responded with status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.body};
      } else {
        return {
          'success': false,
          'message': 'Failed to upload artwork. (${response.statusCode})',
          'response_body': response.body,
        };
      }
    } catch (e, stackTrace) {
      print('[ERROR] Exception during upload: $e');
      print('[STACK TRACE] $stackTrace');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Method GET umum
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl/api$path');
    final response = await http.get(url, headers: headers);
    return response;
  }

  // Method POST umum
  Future<http.Response> post(String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/api$path');
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response;
  }
}