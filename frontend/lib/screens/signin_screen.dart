import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_signup/services/api_service.dart';
import 'admin_dashboard_screen.dart';
import 'user_dashboard_screen.dart';
import 'signup_screen.dart';
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}
class _SignInScreenState extends State<SignInScreen> {
final _formKey = GlobalKey<FormState>();
final emailController = TextEditingController();
final passwordController = TextEditingController();
bool remember = true;
@override
void dispose(){
emailController.dispose();
passwordController.dispose();
super.dispose();
}
// ================= LOGIN =================
Future<void> loginUser() async {
try {
final data = await ApiService.login(
email: emailController.text.trim(),
password: passwordController.text.trim(),
);
final prefs = await SharedPreferences.getInstance();
await prefs.setString(
"username",
data["username"] ?? ""
);
await prefs.setString(
"email",
data["email"] ?? ""
);
await prefs.setString(
"token",
data["token"] ?? ""
);
await prefs.setString(
"role",
data["role"] ?? "user"
);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
data["message"] ?? "Login success"
),
),
);
// ================= ROLE =================
if(data["role"] == "admin"){
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => AdminDashboard_screen(),
),
);
}
else{
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => UserDashboardScreen(),
),
);
}
}
catch(e){
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
e.toString()
),
),
);
}
}
// ================= DESIGN =================
@override
Widget build(BuildContext context) {
return Scaffold(
body: Container(
width: double.infinity,
height: double.infinity,
decoration: const BoxDecoration(
gradient: LinearGradient(
colors:[
Color(0xFF0B1220),
Color(0xFF16324F),
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
),
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(25),
child: Card(
elevation:15,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
child: Padding(
padding: const EdgeInsets.all(25),
child: Form(
key:_formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children:[
// LOGO
Container(
height:85,
width:85,
decoration: const BoxDecoration(
shape: BoxShape.circle,
color: Colors.amber,
),
child: const Icon(
Icons.hive,
size:45,
color: Colors.black,
),
),
const SizedBox(height:20),
const Text(
"Bee Venom AI",
style:TextStyle(
fontSize:28,
fontWeight:FontWeight.bold,
color:Color(0xFF0B1220),
),
),
const SizedBox(height:5),
const Text(
"Intelligent Extraction System",
style:TextStyle(
color:Colors.grey,
fontSize:15,
),
),
const SizedBox(height:30),
// EMAIL
TextFormField(
controller:emailController,
decoration:InputDecoration(
labelText:"Email",
prefixIcon:
const Icon(Icons.email),
filled:true,
fillColor:Colors.grey.shade100,
border:OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
borderSide:
BorderSide.none,
),
),
validator:(v)=>
v!.contains("@")
?
null
:
"Invalid email",
),
const SizedBox(height:15),
// PASSWORD
TextFormField(
controller:passwordController,
obscureText:true,
decoration:InputDecoration(
labelText:"Password",
prefixIcon:
const Icon(Icons.lock),
filled:true,
fillColor:Colors.grey.shade100,
border:OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
borderSide:
BorderSide.none,
),
),
validator:(v)=>
v!.isEmpty
?
"Enter password"
:
null,
),
const SizedBox(height:10),
// REMEMBER
Row(
children:[
Checkbox(
value:remember,
activeColor:Colors.blue,
onChanged:(v){
setState((){
remember=v!;
});
},
),
const Text(
"Remember me"
),
],
),
const SizedBox(height:20),
// BUTTON
SizedBox(
width:double.infinity,
height:55,
child:ElevatedButton(
style:ElevatedButton.styleFrom(
backgroundColor:
const Color(0xFF16324F),
shape:RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
onPressed:(){
if(_formKey.currentState!.validate()){
loginUser();
}
},
child:const Text(
"SIGN IN",
style:TextStyle(
color:Colors.white,
fontSize:18,
fontWeight:FontWeight.bold,
),
),
),
),
const SizedBox(height:15),
// CREATE ACCOUNT
TextButton(
onPressed:(){
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => const SignUpScreen(),
),
);
},
child:const Text(
"Create account",
style:TextStyle(
fontSize:16,
),
),
),
],
),
),
),
),
),
),
),
);
}
}