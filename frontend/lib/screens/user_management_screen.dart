import 'package:flutter/material.dart';
import '../services/user_service.dart';
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key:key);
  @override
  State<UserManagementScreen> createState()
  => _UserManagementScreenState();
}
class _UserManagementScreenState 
extends State<UserManagementScreen>{
List users=[];
@override
void initState(){
super.initState();
loadUsers();
}
Future<void> loadUsers() async{
final data =
await UserService.getUsers();
setState((){
users=data;
});
}
// ================= AJOUTER UTILISATEUR =================
void showAddDialog(){
TextEditingController username =
TextEditingController();
TextEditingController email =
TextEditingController();
TextEditingController password =
TextEditingController();
String role="user";
showDialog(
context:context,
builder:(context){
return AlertDialog(
title:
const Text(
"Ajouter utilisateur"
),
content:
SingleChildScrollView(
child:Column(
mainAxisSize:
MainAxisSize.min,
children:[
TextField(
controller:username,
decoration:
const InputDecoration(
labelText:"Nom utilisateur"
),
),
TextField(
controller:email,
decoration:
const InputDecoration(
labelText:"Email"
),
),
TextField(
controller:password,
obscureText:true,
decoration:
const InputDecoration(
labelText:"Mot de passe"
),
),
DropdownButtonFormField(
value:role,
decoration:
const InputDecoration(
labelText:"Role"
),
items:[
DropdownMenuItem(
value:"user",
child:
Text("Utilisateur")
),
DropdownMenuItem(
value:"admin",
child:
Text("Administrateur")
),
],
onChanged:(value){
role=value.toString();
},
)
]
)
),
actions:[
TextButton(
child:
const Text("Annuler"),
onPressed:(){
Navigator.pop(context);
},
),
ElevatedButton(
child:
const Text("Ajouter"),
onPressed:() async{
await UserService.addUser(
username.text,
email.text,
password.text,
role
);
Navigator.pop(context);
loadUsers();
},
)
],
);
}
);
}
// ================= MODIFIER =================
void showEditDialog(dynamic user){
TextEditingController username =
TextEditingController(
text:user["username"]
);
TextEditingController email =
TextEditingController(
text:user["email"]
);
String role=user["role"];
showDialog(
context:context,
builder:(context){
return AlertDialog(
title:
const Text(
"Modifier utilisateur"
),
content:
Column(
mainAxisSize:
MainAxisSize.min,
children:[
TextField(
controller:username,
decoration:
const InputDecoration(
labelText:"Nom"
),
),
TextField(
controller:email,
decoration:
const InputDecoration(
labelText:"Email"
),
),
DropdownButtonFormField(
value:role,
items:[
DropdownMenuItem(
value:"user",
child:Text("Utilisateur")
),
DropdownMenuItem(
value:"admin",
child:Text("Administrateur")
),
],
onChanged:(value){
role=value.toString();
},
)
]
),
actions:[
TextButton(
child:
const Text("Annuler"),
onPressed:(){
Navigator.pop(context);
},
),
ElevatedButton(
child:
const Text("Enregistrer"),
onPressed:() async{
await UserService.updateUser(
user["id"],
username.text,
email.text,
role
);
Navigator.pop(context);
loadUsers();
},
)
],
);
}
);
}
// ================= INTERFACE =================
@override
Widget build(BuildContext context){
return Scaffold(
backgroundColor:
const Color(0xff08131F),
appBar:
AppBar(
title:
const Text(
"Gestion utilisateurs"
),
actions:[
IconButton(
icon:
const Icon(
Icons.person_add
),
onPressed:(){
showAddDialog();
},
)
]
),
body:
ListView.builder(
itemCount:
users.length,
itemBuilder:(context,index){
final user=users[index];
return Card(
color:
const Color(0xff142536),
child:
ListTile(
leading:
const CircleAvatar(
child:
Icon(
Icons.person
),
),
title:
Text(
user["username"],
style:
const TextStyle(
color:Colors.white
),
),
subtitle:
Text(
"${user["email"]}\nRole : ${user["role"]}",
style:
const TextStyle(
color:Colors.white70
),
),
trailing:
Row(
mainAxisSize:
MainAxisSize.min,
children:[
IconButton(
icon:
const Icon(
Icons.edit,
color:Colors.blue
),
onPressed:(){
showEditDialog(user);
},
),
IconButton(
icon:
const Icon(
Icons.delete,
color:Colors.red
),
onPressed:() async{
await UserService.deleteUser(
user["id"]
);
loadUsers();
},
),
]
),
),
);
},
),
);
}
}