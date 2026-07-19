import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() =>
      _ChatbotScreenState();
}
class _ChatbotScreenState extends State<ChatbotScreen>{
final TextEditingController controller =
TextEditingController();
final ScrollController scrollController =
ScrollController();
List<Map<String,String>> messages = [];
bool loading = false;
@override
void dispose(){
controller.dispose();
scrollController.dispose();
super.dispose();
}
void scrollDown(){
Future.delayed(
const Duration(milliseconds:300),
(){
if(scrollController.hasClients){
scrollController.animateTo(
scrollController.position.maxScrollExtent,
duration:
const Duration(milliseconds:300),
curve:
Curves.easeOut
);
}
}
);
}
Future<void> send() async{
String msg =
controller.text.trim();
if(msg.isEmpty) return;
setState((){
messages.add({
"role":"user",
"text":msg
});
controller.clear();
loading=true;
});
scrollDown();
try{
String response =
await ChatbotService.sendMessage(msg);
setState((){
messages.add({
"role":"bot",
"text":response
});
loading=false;
});
}
catch(e){
setState((){
messages.add({
"role":"bot",
"text":
"Erreur de connexion avec l'assistant IA"
});
loading=false;
});
}
scrollDown();
}
@override
Widget build(BuildContext context){
return Scaffold(
resizeToAvoidBottomInset:true,
backgroundColor:
const Color(0xffF4F7FC),
appBar: AppBar(
automaticallyImplyLeading:false,
elevation:0,
backgroundColor:
Colors.blueAccent,
title:Row(
children:[
Container(
padding:
const EdgeInsets.all(8),
decoration:
BoxDecoration(
color:Colors.white,
borderRadius:
BorderRadius.circular(50)
),
child:
const Icon(
Icons.smart_toy,
color:
Colors.blueAccent
)
),
const SizedBox(width:10),
]
),
),
body:Column(
children:[
Expanded(
child:
ListView.builder(
controller:
scrollController,
padding:
const EdgeInsets.all(15),
itemCount:
messages.length + 
(loading ? 1 : 0),
itemBuilder:(context,index){
if(index == messages.length && loading){
return const Align(
alignment:
Alignment.centerLeft,
child:
Padding(
padding:
EdgeInsets.all(10),
child:
Text(
"🤖 Assistant réfléchit ...",
style:
TextStyle(
color:
Colors.grey,
fontStyle:
FontStyle.italic
)
)
)
);
}
bool isUser =
messages[index]["role"]=="user";
return Align(
alignment:
isUser
?
Alignment.centerRight
:
Alignment.centerLeft,
child:
Container(
margin:
const EdgeInsets.only(
bottom:12
),
padding:
const EdgeInsets.all(15),
constraints:
BoxConstraints(
maxWidth:
MediaQuery.of(context)
.size.width * 0.75
),
decoration:
BoxDecoration(
color:
isUser
?
Colors.blueAccent
:
Colors.white,
borderRadius:
BorderRadius.only(
topLeft:
const Radius.circular(20),
topRight:
const Radius.circular(20),
bottomLeft:
Radius.circular(
isUser ? 20 : 5
),
bottomRight:
Radius.circular(
isUser ? 5 : 20
),
),
boxShadow:[
BoxShadow(
color:
Colors.black12,
blurRadius:5,
offset:
const Offset(0,3)
)
]
),
child:Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
Icon(
isUser
?
Icons.person
:
Icons.smart_toy,
color:
isUser
?
Colors.white
:
Colors.blueAccent,
size:22
),
const SizedBox(width:10),
Expanded(
child:
Text(
messages[index]["text"]!,
style:
TextStyle(
fontSize:15,
color:
isUser
?
Colors.white
:
Colors.black87
)
)
)
]
)
)
);
}
)
),
// ZONE MESSAGE
Container(
padding:
const EdgeInsets.symmetric(
horizontal:15,
vertical:10
),
decoration:
const BoxDecoration(
color:
Colors.white,
boxShadow:[
BoxShadow(
color:
Colors.black12,
blurRadius:8
)
]
),
child:
Row(
children:[
Expanded(
child:
TextField(
controller:
controller,
onSubmitted:(value){
send();
},
decoration:
InputDecoration(
hintText:
"Posez votre question...",
prefixIcon:
const Icon(
Icons.chat
),
filled:true,
fillColor:
Colors.grey.shade100,
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(30),
borderSide:
BorderSide.none
)
)
)
),
const SizedBox(width:10),
CircleAvatar(
radius:25,
backgroundColor:
Colors.blueAccent,
child:
IconButton(
icon:
const Icon(
Icons.send,
color:
Colors.white
),
onPressed:
send
)
)
]
)
)
]
)
);
}
}