import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.16:5000/api'; // Pour Android Emulator

  // Basic registration with only email and password
  static Future<bool> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      print('✅ Registered successfully');
      return true;
    } else {
      print('❌ Failed to register: ${response.body}');
      return false;
    }
  }

  // Extended registration with profile details
  static Future<bool> registerWithDetails(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      print('✅ Registered with details successfully');
      return true;
    } else {
      print('❌ Failed to register with details: ${response.body}');
      return false;
    }
  }
}