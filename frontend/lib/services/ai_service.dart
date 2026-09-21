import 'dart:convert';
import 'package:http/http.dart' as http;


class AiService {


  static const String baseUrl =
      "http://192.168.1.200:5000";



  static Future<Map<String,dynamic>> predict(
      Map<String,dynamic> data
      ) async{


    try{


      // Ajouter l'utilisateur connecté
      data["user_id"] = 4;



      final response =
      await http.post(

        Uri.parse(
            "$baseUrl/ai/predict"
        ),


        headers:{

          "Content-Type":
          "application/json"

        },


        body:

        jsonEncode(data)

      );



      print("AI RESPONSE : ${response.body}");



      final result =
      jsonDecode(response.body);



      if(result["status"] == true){


        return {


          "state":
          result["state"],


          "extraction":
          result["extraction"],


          "confidence":
          result["confidence"],


          "features":
          result["features"],


        };


      }


      return {};



    }

    catch(e){


      print(
          "AI ERROR : $e"
      );


      return {};


    }

  }

}