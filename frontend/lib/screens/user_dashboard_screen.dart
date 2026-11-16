import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:login_signup/screens/history_screen.dart';
import 'package:login_signup/services/sensor_service.dart';
import 'package:login_signup/services/ai_service.dart';
import 'monitoring_screen.dart';
import 'prediction_screen.dart';
import 'chatbot_screen.dart';
import 'history_screen.dart';
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key:key);
  @override
  State<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}
class _UserDashboardScreenState
    extends State<UserDashboardScreen>{
int currentIndex = 0;
double weight = 0;
double temperature = 0;
double humidity = 0;
double vibration = 0;
String beeState = "En attente";
String extractionResult = "En attente";
double confidence = 0;
// features venant du modèle IA
Map<String,dynamic> features = {};
Timer? timer;
final List<String> titles = [
"Dashboard",
"Prédictions",
"Monitoring",
"Chatbot",
"Historique"
];
@override
void initState(){
super.initState();
loadSensorData();
timer = Timer.periodic(
const Duration(seconds:3),
(e){
loadSensorData();
}
);
}
@override
void dispose(){
timer?.cancel();
super.dispose();
}
// ================= SENSOR + IA =================
Future<void> loadSensorData() async{
try{
final data =
await SensorService.getLastSensor();
setState((){
weight =
double.tryParse(
data["weight"].toString()
) ?? 0;
temperature =
double.tryParse(
data["temperature"].toString()
) ?? 0;
humidity =
double.tryParse(
data["humidity"].toString()
) ?? 0;
vibration =
double.tryParse(
data["vibration"].toString()
) ?? 0;
});
final prediction =
await AiService.predict({
"weight":weight,
"temperature":temperature,
"humidity":humidity,
"vibration":vibration
});
setState((){
beeState =
prediction["state"] ?? "unknown";
extractionResult =
prediction["extraction"] ?? "unknown";
confidence =
double.tryParse(
prediction["confidence"].toString()
) ?? 0;
// récupération des features ML
features =
prediction["features"] ?? {};
// correction confiance
if(confidence <= 1){
confidence = confidence * 100;
}
});
}
catch(e){
print(e);
}
}
@override
Widget build(BuildContext context){
return Container(
decoration:
const BoxDecoration(
gradient:
LinearGradient(
colors:[
Color(0xFF0A141E),
Color(0xFF16324F),
Color(0xFF050A12)
],
begin:
Alignment.topLeft,
end:
Alignment.bottomRight
)
),
child:
Scaffold(
backgroundColor:
Colors.transparent,
appBar:
AppBar(
backgroundColor:
const Color(0xFF16324F),
title:
Text(
titles[currentIndex],
style:
const TextStyle(
color:Colors.white,
fontWeight:FontWeight.bold
)
),
),
body:
IndexedStack(
index:
currentIndex,
children:[
dashboardPage(),
const PredictionScreen(),
const MonitoringScreen(),
const ChatbotScreen(),
const HistoryScreen(),
],
),
bottomNavigationBar:
BottomNavigationBar(
currentIndex:
currentIndex,
type:
BottomNavigationBarType.fixed,
backgroundColor:
const Color(0xFF0A141E),
selectedItemColor:
Colors.blue,
unselectedItemColor:
Colors.grey,
onTap:(index){
setState((){
currentIndex=index;
});
},
items:
const[
BottomNavigationBarItem(
icon:Icon(Icons.dashboard),
label:"Dashboard"
),
BottomNavigationBarItem(
icon:Icon(Icons.psychology),
label:"Prédictions"
),
BottomNavigationBarItem(
icon:Icon(Icons.monitor_heart),
label:"Monitoring"
),
BottomNavigationBarItem(
icon:Icon(Icons.chat),
label:"Chatbot"
),
BottomNavigationBarItem(
  icon: Icon(Icons.settings),
  label: "Paramètres"
),
],
),
),
);
}
// ================= DASHBOARD PAGE =================
Widget dashboardPage(){
return SingleChildScrollView(
padding:
const EdgeInsets.all(8),
child:Column(
children:[
const SizedBox(height:8),
// ================= CAPTEURS =================
Row(
children:[
sensorCard(
Icons.scale,
"Poids",
"${weight.toStringAsFixed(2)} g",
Colors.blue
),
const SizedBox(width:10),
sensorCard(
Icons.thermostat,
"Température",
"${temperature.toStringAsFixed(2)} °C",
Colors.red
),
],
),
const SizedBox(height:8),
Row(
children:[
sensorCard(
Icons.water_drop,
"Humidité",
"${humidity.toStringAsFixed(2)} %",
Colors.green
),
const SizedBox(width:10),
sensorCard(
Icons.vibration,
"Vibration",
vibration.toStringAsFixed(3),
Colors.orange
),
],
),
const SizedBox(height:10),
// ================= DECISION IA =================
predictionCard(),
const SizedBox(height:10),
// ================= FEATURES IA =================
featureChart(),
],
),
);
}
// ================= SENSOR CARD =================
Widget sensorCard(
IconData icon,
String title,
String value,
Color color
){
return Expanded(
child:Card(
color:
const Color(0xFF141E2D),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(8)
),
child:Padding(
padding:
const EdgeInsets.all(8),
child:Column(
children:[
Icon(
icon,
color:color,
size:35
),
const SizedBox(height:10),
Text(
value,
style:
TextStyle(
color:color,
fontSize:18,
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
),
]
)
)
)
);
}
// ================= IA CARD =================
Widget predictionCard(){
Color stateColor;
if(beeState.toLowerCase()=="optimal"){
stateColor = Colors.green;
}
else if(beeState.toLowerCase()=="stress"){
stateColor = Colors.red;
}
else{
stateColor = Colors.orange;
}
return Card(
color:
const Color(0xFF141E2D),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(8)
),
child:Padding(
padding:
const EdgeInsets.all(20),
child:Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
const Row(
children:[
Icon(
Icons.psychology,
color:Colors.blue,
size:35
),
SizedBox(width:10),
Text(
"Décision IA",
style:
TextStyle(
color:Colors.white,
fontSize:20,
fontWeight:
FontWeight.bold
)
)
]
),
const SizedBox(height:10),
Row(
children:[
const Text(
"Etat abeilles : ",
style:
TextStyle(
color:Colors.white70,
fontSize:16
)
),
Text(
beeState.toUpperCase(),
style:
TextStyle(
color:stateColor,
fontSize:17,
fontWeight:
FontWeight.bold
)
)
]
),
const SizedBox(height:12),
Row(
children:[
const Text(
"Extraction : ",
style:
TextStyle(
color:Colors.white70,
fontSize:16
)
),
Text(
extractionResult,
style:
const TextStyle(
color:Colors.amber,
fontSize:17,
fontWeight:
FontWeight.bold
)
)
]
),
const SizedBox(height:12),
Row(
children:[
const Text(
"Confiance IA : ",
style:
TextStyle(
color:Colors.white70
)
),
Text(
"${confidence.toStringAsFixed(1)} %",
style:
const TextStyle(
color:Colors.blue,
fontWeight:
FontWeight.bold
)
)
]
)
]
)
)
);
}
// ================= FEATURES CHART =================
Widget featureChart(){
double tempMean =
double.tryParse(
features["temp_mean_1h"].toString()
) ?? 0;
double tempVariation =
double.tryParse(
features["temp_variation"].toString()
) ?? 0;
double humidityCombined =
double.tryParse(
features["humidity_combined"].toString()
) ?? 0;
double thermalStress =
double.tryParse(
features["thermal_stress"].toString()
) ?? 0;
double vibrationSpike =
double.tryParse(
features["vibration_spike"].toString()
) ?? 0;
double activityScore =
double.tryParse(
features["activity_score"].toString()
) ?? 0;
return Card(
color:
const Color(0xFF141E2D),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(18)
),
child:Padding(
padding:
const EdgeInsets.all(15),
child:Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
const Text(
"📊 Features intelligentes IA",
style:
TextStyle(
color:Colors.white,
fontSize:15,
fontWeight:
FontWeight.bold
)
),
const SizedBox(height:20),
SizedBox(
height:180,
child:LineChart(
LineChartData(
gridData:
const FlGridData(
show:true
),
borderData:
FlBorderData(
show:false
),
titlesData:
const FlTitlesData(
show:true
),
lineBarsData:[
LineChartBarData(
isCurved:true,
barWidth:3,
spots:[
FlSpot(0,tempMean),
FlSpot(1,tempVariation),
FlSpot(2,humidityCombined),
FlSpot(3,thermalStress),
FlSpot(4,vibrationSpike),
FlSpot(5,activityScore),
]
)
]
)
)
)
]
)
)
);
}
// ================= SETTINGS =================
Widget settingsPage(){
return const Center(
child:Text(
"Paramètres système",
style:
TextStyle(
color:Colors.white,
fontSize:18
)
)
);
}
    }