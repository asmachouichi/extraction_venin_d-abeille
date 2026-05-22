import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorService {

  static const String baseUrl = "http://192.168.1.200:5000";

  // ================= GET SENSORS =================
  static Future<List<dynamic>> getSensors() async {

    final response = await http.get(
      Uri.parse("$baseUrl/sensors/"), // ✅ IMPORTANT: slash final
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to load sensors: ${response.statusCode}"
      );
    }
  }

  // ================= POST SENSOR (OPTIONAL ESP32 TEST) =================
  static Future<void> sendSensorData(Map<String, dynamic> data) async {

    final response = await http.post(
      Uri.parse("$baseUrl/sensors/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to send sensor data");
    }
  }
}