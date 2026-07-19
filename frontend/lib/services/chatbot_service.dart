import 'dart:convert';
import 'package:http/http.dart' as http;
class ChatbotService{
static const String url =
"http://192.168.1.200:5000/ai/chat";
static Future<String> sendMessage(
String message
) async {
final response =
await http.post(
Uri.parse(url),
headers:{
"Content-Type":"application/json"
},
body:jsonEncode({
"message":message
})
);
if(response.statusCode==200){
final data=jsonDecode(response.body);
return data["answer"];
}
return "Erreur serveur";
}
}