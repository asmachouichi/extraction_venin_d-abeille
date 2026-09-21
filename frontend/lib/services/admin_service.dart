import 'dart:convert';
import 'package:http/http.dart' as http;
class AdminService {
  static const String baseUrl =
      "http://10.0.2.2:5000";
  // =====================================================
  // STATISTIQUES ADMIN
  // =====================================================
  static Future<Map<String,dynamic>>
  getStatistics() async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/admin/statistics"
      )
    );
    print("STATISTICS : ${response.body}");
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
          "Erreur statistiques"
      );
    }
  }
  // =====================================================
  // GESTION UTILISATEURS
  // =====================================================
  // Afficher utilisateurs
  static Future<List<dynamic>>
  getUsers() async{
    final response = await http.get(
        Uri.parse(
            "$baseUrl/admin/users"
        )
    );
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
          "Erreur chargement utilisateurs"
      );
    }
  }
  // Supprimer utilisateur
  static Future<void>
  deleteUser(int id) async{
    final response = await http.delete(
        Uri.parse(
            "$baseUrl/admin/users/$id"
        )
    );
    if(response.statusCode != 200){
      throw Exception(
          "Erreur suppression utilisateur"
      );
    }
  }
  // =====================================================
  // GESTION EXTRACTIONS
  // =====================================================
  // Afficher extractions
  static Future<List<dynamic>>
  getExtractions() async{
    final response = await http.get(
        Uri.parse(
            "$baseUrl/admin/extractions"
        )
    );
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
          "Erreur chargement extractions"
      );
    }
  }
  // =====================================================
  // GESTION ALERTES
  // =====================================================
  // Afficher toutes les alertes
  static Future<List<dynamic>>
  getAlerts() async{
    final response = await http.get(
        Uri.parse(
            "$baseUrl/admin/alerts"
        )
    );
    print("ALERT STATUS : ${response.statusCode}");
    print("ALERT BODY : ${response.body}");
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
          "Erreur chargement alertes"
      );
    }
  }
  // Marquer alerte comme lue
  static Future<void>
  readAlert(int id) async{
    final response = await http.put(
        Uri.parse(
            "$baseUrl/admin/alerts/read/$id"
        )
    );
    if(response.statusCode != 200){
      throw Exception(
          "Erreur lecture alerte"
      );
    }
  }
  // Supprimer alerte
  static Future<void>
  deleteAlert(int id) async{
    final response = await http.delete(
        Uri.parse(
            "$baseUrl/admin/alerts/$id"
        )
    );
    if(response.statusCode != 200){
      throw Exception(
          "Erreur suppression alerte"
      );
    }
  }
  // =====================================================
  // PARAMETRES SYSTEME
  // =====================================================
  // Lire paramètres
  static Future<Map<String,dynamic>>
  getSettings() async{
    final response = await http.get(
        Uri.parse(
            "$baseUrl/settings"
        )
    );
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    else{
      throw Exception(
          "Erreur paramètres"
      );
    }
  }
  // Modifier paramètres
  static Future<void>
  updateSettings(
      Map<String,dynamic> data
      ) async{
    final response = await http.put(
        Uri.parse(
            "$baseUrl/settings/update"
        ),
        headers:{
          "Content-Type":
          "application/json"
        },
        body:
        jsonEncode(data)
    );
    if(response.statusCode != 200){
      throw Exception(
          "Erreur modification paramètres"
      );
    }
  }
}