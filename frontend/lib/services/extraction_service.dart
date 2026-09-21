import 'dart:convert';
import 'package:http/http.dart' as http;
class ExtractionService {
  static const String url =
      "http://10.0.2.2:5000/admin/extractions";
  static Future<List<dynamic>> getExtractions() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Erreur");
  }
}