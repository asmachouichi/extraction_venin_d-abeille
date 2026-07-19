import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_model.dart';
class SensorService {
  static const String baseUrl = "http://192.168.1.200:5000";
  // ======================================================
  // =============== CSV LOCAL DATA =======================
  // ORDER FIXED:
  // timestamp, weight, temperature, humidity, vibration
  // ======================================================
  static Future<List<SensorData>> loadCsvData() async {
    final rawData = await rootBundle.loadString('assets/sensors.csv');
    List<List<dynamic>> rows =
        const CsvToListConverter().convert(rawData);
    rows.removeAt(0); // remove header
    return rows.map((row) {
      return SensorData(
        time: row[0].toString(), // timestamp
        // IMPORTANT: correct mapping
        weight: _toDouble(row[1]),
        temperature: _toDouble(row[2]),
        humidity: _toDouble(row[3]),
        vibration: _toDouble(row[4]),
      );
    }).toList();
  }
  // ======================================================
  // =============== SAFE CONVERTER =======================
  // FIXES wrong type (String/int/double mix issues)
  // ======================================================
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
  // ======================================================
  // =============== LAST SENSOR ==========================
  // ======================================================
  static Future<Map<String, dynamic>> getLastSensor() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/sensors/last"))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return _emptySensor();
      }
    } catch (e) {
      print("GET LAST SENSOR ERROR: $e");
      return _emptySensor();
    }
  }
  // ======================================================
  // =============== ALL SENSORS ==========================
  // ======================================================
  static Future<List<dynamic>> getSensors() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/sensors/"))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("GET SENSORS ERROR: $e");
      return [];
    }
  }
  // ======================================================
  // =============== SEND SENSOR ==========================
  // ======================================================
  static Future<void> sendSensorData(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/sensors"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 201) {
        throw Exception("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("POST SENSOR ERROR: $e");
    }
  }
  // ======================================================
  // =============== EMPTY SAFE VALUE =====================
  // ======================================================
  static Map<String, dynamic> _emptySensor() {
    return {
      "weight": 0,
      "temperature": 0,
      "humidity": 0,
      "vibration": 0,
    };
  }
}