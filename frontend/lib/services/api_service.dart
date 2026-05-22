import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://10.0.2.2:5000";

  // ================= SIGNUP =================
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Signup failed");
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  // ================= SENSOR =================
  static Future<Map<String, dynamic>> getSensorData(String token) async {

    final response = await http.get(
      Uri.parse("$baseUrl/sensors"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception("Failed to load sensors");
    }
  }
}