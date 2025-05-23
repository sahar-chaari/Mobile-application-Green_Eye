import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.1.16:5000/api';

  /// Register user
  static Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return response.statusCode == 201;
  }

  /// Login user and return token
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }

  /// Get user ID by email after login
  static Future<String?> getUserIdByEmail(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/email/$email'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['_id'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching userId: $e');
      return null;
    }
  }
}