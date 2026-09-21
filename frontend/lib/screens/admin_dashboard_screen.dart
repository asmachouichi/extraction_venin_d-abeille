import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'user_management_screen.dart';
import 'extraction_management_screen.dart';
import 'alert_management_screen.dart';
class AdminDashboardScreen extends StatefulWidget {
const AdminDashboardScreen({Key? key})
: super(key:key);
@override
State<AdminDashboardScreen> createState()
=> _AdminDashboardScreenState();
}
class _AdminDashboardScreenState 
extends State<AdminDashboardScreen>{
String adminName="Administrateur";
int users=0;
int extractions=0;
int alerts=0;
@override
void initState(){
super.initState();
loadStatistics();
}
Future<void> loadStatistics() async{
try{
final data =
await AdminService.getStatistics();
if(!mounted)return;
setState((){
users =
int.tryParse(
data["users"].toString()
) ?? 0;
extractions =
int.tryParse(
data["extractions"].toString()
) ?? 0;
alerts =
int.tryParse(
data["alerts"].toString()
) ?? 0;
});
}
catch(e){
print(
"Erreur statistiques : $e"
);
}
}
@override
Widget build(BuildContext context){
return Scaffold(
backgroundColor:
const Color(0xff08131F),
appBar:
AppBar(
backgroundColor:
const Color(0xff16324F),
centerTitle:true,
title:
const Text(
"Admin Dashboard",
style:
TextStyle(
color:Colors.white,
fontWeight:
FontWeight.bold
)
),
),
body:
SingleChildScrollView(
padding:
const EdgeInsets.all(20),
child:
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
// =================
// PROFIL ADMIN
// =================
Card(
color:
const Color(0xff142536),
child:
Padding(
padding:
const EdgeInsets.all(15),
child:
Row(
children:[
const CircleAvatar(
radius:30,
backgroundColor:
Colors.blue,
child:
Icon(
Icons.admin_panel_settings,
color:Colors.white,
size:35,
),
),
const SizedBox(width:15),
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
Text(
"Bienvenue $adminName",
style:
const TextStyle(
color:Colors.white,
fontSize:20,
fontWeight:
FontWeight.bold
)
),
const SizedBox(height:5),
const Text(
"Gestion du système IoT",
style:
TextStyle(
color:Colors.white70
)
),
],
)
],
),
),
),
const SizedBox(height:20),
// =================
// STATISTIQUES
// =================
Row(
children:[
statCard(
Icons.people,
"Utilisateurs",
users.toString(),
Colors.blue
),
const SizedBox(width:10),
statCard(
Icons.science,
"Extractions",
extractions.toString(),
Colors.orange
),
const SizedBox(width:10),
statCard(
Icons.warning,
"Alertes",
alerts.toString(),
Colors.red
),
],
),
const SizedBox(height:30),
const Text(
"Gestion",
style:
TextStyle(
color:Colors.white,
fontSize:22,
fontWeight:
FontWeight.bold
),
),
const SizedBox(height:15),
menuCard(
Icons.people,
"Gestion utilisateurs",
(){
Navigator.push(
context,
MaterialPageRoute(
builder:(context)
=> const UserManagementScreen()
)
).then((value){
loadStatistics();
});
}
),
menuCard(
Icons.science,
"Gestion extractions",
(){
Navigator.push(
context,
MaterialPageRoute(
builder:(context)
=> const ExtractionManagementScreen()
)
);
}
),
menuCard(
Icons.warning,
"Gestion alertes",
(){
Navigator.push(
context,
MaterialPageRoute(
builder:(context)
=> const AlertManagementScreen()
)
).then((value){
loadStatistics();
});
}
),
menuCard(
Icons.settings,
"Paramètres système",
(){
print(
"Paramètres système"
);
}
),
],
),
),
// ==========================
// FOOTER
// ==========================
bottomNavigationBar:
Container(
height:75,
decoration:
const BoxDecoration(
color:
Color(0xff16324F),
borderRadius:
BorderRadius.only(
topLeft:
Radius.circular(20),
topRight:
Radius.circular(20)
)
),
child:
Row(
mainAxisAlignment:
MainAxisAlignment.spaceAround,
children:[
footerItem(
Icons.dashboard,
"Accueil",
(){
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder:(context)
=> const AdminDashboardScreen()
)
);
}
),
footerItem(
Icons.people,
"Users",
(){
Navigator.push(
context,
MaterialPageRoute(
builder:(context)
=> const UserManagementScreen()
)
);
}
),
footerItem(
Icons.science,
"Extraction",
(){
Navigator.push(
context,
MaterialPageRoute(
builder:(context)
=> const ExtractionManagementScreen()
)
);
}
),
footerItem(
Icons.settings,
"Paramètres",
(){
print(
"Paramètres système"
);
}
),
],
),
),
);
}
// ==========================
// STAT CARD
// ==========================
Widget statCard(
IconData icon,
String title,
String value,
Color color
){
return Expanded(
child:
Card(
color:
const Color(0xff142536),
child:
Padding(
padding:
const EdgeInsets.all(15),
child:
Column(
children:[
Icon(
icon,
color:color,
size:30,
),
const SizedBox(height:10),
Text(
value,
style:
TextStyle(
color:color,
fontSize:25,
fontWeight:
FontWeight.bold
)
),
Text(
title,
style:
const TextStyle(
color:Colors.white70
)
)
],
),
),
),
);
}
// ==========================
// MENU CARD
// ==========================
Widget menuCard(
IconData icon,
String title,
VoidCallback action
){
return Card(
color:
const Color(0xff142536),
child:
ListTile(
leading:
Icon(
icon,
color:Colors.blue,
),
title:
Text(
title,
style:
const TextStyle(
color:Colors.white
)
),
trailing:
const Icon(
Icons.arrow_forward_ios,
color:Colors.white70,
size:18,
),
onTap:action,
),
);
}
// ==========================
// FOOTER ITEM
// ==========================
Widget footerItem(
IconData icon,
String title,
VoidCallback onTap
){
return InkWell(
onTap:onTap,
child:
Column(
mainAxisAlignment:
MainAxisAlignment.center,
children:[
Icon(
icon,
color:Colors.white,
size:25,
),
Text(
title,
style:
const TextStyle(
color:Colors.white70,
fontSize:12
)
)
],
),
);
}
}