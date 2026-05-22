import 'dart:convert';
import 'package:http/http.dart' as http;

class ControlService {

  // 🔥 IMPORTANT : mettre la BONNE IP de ton Flask
  // ton serveur = http://192.168.1.200:5000
  static const String baseUrl =
      "http://192.168.1.200:5000/control";

  // ================= START EXTRACTION =================
  static Future<bool> startExtraction() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/start"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("START RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == true;
      }

      return false;
    } catch (e) {
      print("START ERROR: $e");
      return false;
    }
  }

  // ================= STOP EXTRACTION =================
  static Future<bool> stopExtraction() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stop"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("STOP RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == false;
      }

      return false;
    } catch (e) {
      print("STOP ERROR: $e");
      return false;
    }
  }

  // ================= GET STATUS =================
  static Future<bool> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/status"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("STATUS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] ?? false;
      }

      return false;
    } catch (e) {
      print("STATUS ERROR: $e");
      return false;
    }
  }
}