import 'dart:convert';
import 'package:http/http.dart' as http;
class UserService{
static String url =
"http://10.0.2.2:5000/admin/users";
// =======================
// Récupérer utilisateurs
// =======================
static Future<List<dynamic>> getUsers() async{
final response =
await http.get(
Uri.parse(url)
);
if(response.statusCode==200){
return jsonDecode(response.body);
}
else{
throw Exception(
"Erreur chargement users"
);
}
}
// =======================
// Ajouter utilisateur
// =======================
static Future<void> addUser(
String username,
String email,
String password,
String role
) async{
final response =
await http.post(
Uri.parse(url),
headers:{
"Content-Type":
"application/json"
},
body:
jsonEncode({
"username":username,
"email":email,
"password":password,
"role":role
})
);
if(response.statusCode!=200 &&
response.statusCode!=201){
throw Exception(
"Erreur ajout utilisateur"
);
}
}
// =======================
// Supprimer utilisateur
// =======================
static Future<void> deleteUser(int id) async{
final response =
await http.delete(
Uri.parse(
"$url/$id"
)
);
if(response.statusCode!=200){
throw Exception(
"Erreur suppression"
);
}
}
// =======================
// Modifier utilisateur
// =======================
static Future<void> updateUser(
int id,
String username,
String email,
String role
) async{
final response =
await http.put(
Uri.parse(
"$url/$id"
),
headers:{
"Content-Type":
"application/json"
},
body:
jsonEncode({
"username":username,
"email":email,
"role":role
})
);
if(response.statusCode!=200){
throw Exception(
"Erreur modification"
);
}
}
}