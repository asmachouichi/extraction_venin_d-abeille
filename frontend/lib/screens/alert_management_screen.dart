import 'package:flutter/material.dart';
import '../services/admin_service.dart';
class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({Key? key})
      : super(key: key);
  @override
  State<AlertManagementScreen> createState()
      => _AlertManagementScreenState();
}
class _AlertManagementScreenState
    extends State<AlertManagementScreen>{
  List alerts = [];
  bool loading = true;
  @override
  void initState(){
    super.initState();
    loadAlerts();
  }
  // =====================================
  // Charger les alertes
  // =====================================
  Future<void> loadAlerts() async{
    try{
      setState((){
        loading = true;
      });
      final data =
      await AdminService.getAlerts();
      setState((){
        alerts = data;
        loading = false;
      });
    }
    catch(e){
      print(e);
      setState((){
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text("Erreur chargement alertes")
          )
      );
    }
  }
  // =====================================
  // Marquer comme lu
  // =====================================
  Future<void> markAsRead(int id) async{
    try{
      await AdminService.readAlert(id);
      loadAlerts();
    }
    catch(e){
      print(e);
    }
  }
  // =====================================
  // Supprimer alerte
  // =====================================
  Future<void> deleteAlert(int id) async{
    try{
      await AdminService.deleteAlert(id);
      loadAlerts();
    }
    catch(e){
      print(e);
    }
  }
  // =====================================
  // Couleur selon gravité
  // =====================================
  Color getSeverityColor(String severity){
    switch(severity){
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:
      const Color(0xff08131F),
      appBar: AppBar(
        backgroundColor:
        const Color(0xff16324F),
        title:
        const Text(
          "Gestion des Alertes",
          style:
          TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),
        ),
        actions:[
          IconButton(
              onPressed: (){
                loadAlerts();
              },
              icon:
              const Icon(
                  Icons.refresh,
                  color: Colors.white
              )
          )
        ],
      ),
      body:
      loading ?
      const Center(
          child:
          CircularProgressIndicator()
      )
          :
      alerts.isEmpty ?
      const Center(
          child:
          Text(
              "Aucune alerte",
              style:
              TextStyle(
                  color: Colors.white,
                  fontSize:18
              )
          )
      )
          :
      ListView.builder(
          padding:
          const EdgeInsets.all(15),
          itemCount:
          alerts.length,
          itemBuilder:
              (context,index){
            return alertCard(
                alerts[index]
            );
          }
      ),
    );
  }
  // =====================================
  // Carte alerte
  // =====================================
  Widget alertCard(dynamic alert){
    Color severityColor =
    getSeverityColor(
        alert["severity"] ?? ""
    );
    return Card(
      color:
      const Color(0xff142536),
      margin:
      const EdgeInsets.only(
          bottom:15
      ),
      child:
      Padding(
        padding:
        const EdgeInsets.all(15),
        child:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children:[
            // TITRE
            Row(
              children:[
                Icon(
                    Icons.warning,
                    color:
                    severityColor,
                    size:35
                ),
                const SizedBox(width:10),
                Expanded(
                    child:
                    Text(
                      alert["type"] ?? "Alerte",
                      style:
                      const TextStyle(
                          color:Colors.white,
                          fontSize:18,
                          fontWeight:
                          FontWeight.bold
                      ),
                    )
                )
              ],
            ),
            const SizedBox(height:15),
            // MESSAGE
            Text(
              alert["message"] ?? "",
              style:
              const TextStyle(
                  color:Colors.white70,
                  fontSize:15
              ),
            ),
            const SizedBox(height:15),
            // UTILISATEUR + STATUT
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children:[
                Text(
                  "Utilisateur : ${alert["username"] ?? "Inconnu"}",
                  style:
                  const TextStyle(
                      color:Colors.white54
                  ),
                ),
                Text(
                  alert["status"] ?? "",
                  style:
                  TextStyle(
                      color:
                      severityColor,
                      fontWeight:
                      FontWeight.bold
                  ),
                )
              ],
            ),
            const SizedBox(height:10),
            Text(
              "Date : ${alert["created_at"] ?? alert["date"] ?? ""}",
              style:
              const TextStyle(
                  color:Colors.white38
              ),
            ),
            const SizedBox(height:15),
            // BOUTONS
            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children:[
                ElevatedButton.icon(
                    onPressed: (){
                      markAsRead(
                          alert["id"]
                      );
                    },
                    icon:
                    const Icon(
                        Icons.check
                    ),
                    label:
                    const Text(
                        "Lire"
                    )
                ),
                const SizedBox(width:10),
                ElevatedButton.icon(
                    style:
                    ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.red
                    ),
                    onPressed: (){
                      deleteAlert(
                          alert["id"]
                      );
                    },
                    icon:
                    const Icon(
                        Icons.delete
                    ),
                    label:
                    const Text(
                        "Supprimer"
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}