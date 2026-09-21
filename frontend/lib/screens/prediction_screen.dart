import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sensor_service.dart';
import '../services/ai_service.dart';
import '../services/control_service.dart';
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({
    Key? key
  }) : super(key:key);
  @override
  State<PredictionScreen> createState()
      => _PredictionScreenState();
}
class _PredictionScreenState
    extends State<PredictionScreen>{
Timer? timer;
Map<String,dynamic> sensor = {};
Map<String,dynamic> features = {};
// ===== RESULTAT IA =====
String extraction = "";
String state = "";
double confidence = 0;
// indique si bouton IA a été utilisé
bool analyzed = false;
bool running = false;
@override
void initState(){
super.initState();
loadSensor();
timer = Timer.periodic(
const Duration(seconds:3),
(e){
loadSensor();
}
);
}
@override
void dispose(){
timer?.cancel();
super.dispose();
}
// ================= GET SENSOR =================
Future<void> loadSensor() async{
try{
final result =
await SensorService.getLastSensor();
if(mounted){
setState((){
sensor = result;
});
}
}
catch(e){
print(e);
}
}
// ================= AI PREDICTION =================
Future<void> runAI() async{
try{
final result =
await AiService.predict(sensor);
print(
"AI RESULT : $result"
);
if(mounted){
setState((){
analyzed = true;
state =
(result["state"] ?? "")
.toString()
.toLowerCase();
extraction =
(result["extraction"] ?? "")
.toString()
.toLowerCase();
confidence =
double.tryParse(
result["confidence"]
.toString()
)
??0;
if(confidence <= 1){
confidence = confidence * 100;
}
features =
result["features"] ?? {};
});
}
}
catch(e){
print(e);
}
}
// ================= STATE COLOR =================
Color stateColor(){
if(!analyzed){
return Colors.orange;
}
if(state=="optimal"){
return Colors.green;
}
if(state=="normal"){
return Colors.orange;
}
if(state=="stress"){
return Colors.red;
}
return Colors.grey;
}
// ================= EXTRACTION COLOR =================
Color extractionColor(){
if(!analyzed){
return Colors.orange;
}
if(extraction=="favorable"){
return Colors.green;
}
return Colors.red;
}
// ================= CONFIDENCE CIRCLE =================
Widget confidenceCircle(){
return SizedBox(
width:95,
height:95,
child:Stack(
alignment:Alignment.center,
children:[
SizedBox(
width:80,
height:80,
child:CircularProgressIndicator(
value:
analyzed
?
confidence/100
:
0,
strokeWidth:8,
backgroundColor:
Colors.grey.shade300,
color:
Colors.blue,
)
),
Text(
"${confidence.toInt()}%",
style:
const TextStyle(
fontSize:20,
fontWeight:
FontWeight.bold
)
)
]
)
);
}
// ================= STATE BOX =================
Widget stateBox(){
return Container(
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:Colors.white,
borderRadius:
BorderRadius.circular(12)
),
child:
Row(
children:[
Icon(
Icons.health_and_safety,
color:stateColor(),
size:30
),
const SizedBox(width:15),
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
const Text(
"Etat des abeilles",
style:
TextStyle(
fontSize:14
)
),
Text(
!analyzed
?
"EN ATTENTE"
:
state.toUpperCase(),
style:
TextStyle(
fontSize:20,
fontWeight:
FontWeight.bold,
color:
stateColor()
)
)
]
)
]
)
);
}
// ================= SENSOR CARD =================
Widget sensorCard(
String title,
String value,
IconData icon,
Color color
){
return Container(
height:75,
padding:
const EdgeInsets.all(4),
decoration:
BoxDecoration(
color:Colors.white,
borderRadius:
BorderRadius.circular(10)
),
child:
Column(
mainAxisAlignment:
MainAxisAlignment.center,
children:[
Icon(
icon,
size:22,
color:color
),
Text(
title,
style:
const TextStyle(
fontSize:11
)
),
Text(
value,
style:
TextStyle(
fontSize:12,
fontWeight:
FontWeight.bold,
color:color
)
)
]
)
);
}
// ================= FEATURE LINE =================
Widget featureLine(
String title,
String value
){
return Padding(
padding:
const EdgeInsets.symmetric(
vertical:3
),
child:
Row(
children:[
Expanded(
child:
Text(
title,
style:
const TextStyle(
fontSize:13
)
)
),
Text(
value,
style:
const TextStyle(
fontSize:13,
fontWeight:
FontWeight.bold
)
)
]
)
);
}
// ================= FEATURE BOX =================
Widget featureBox(){
return Container(
padding:
const EdgeInsets.all(10),
decoration:
BoxDecoration(
color:Colors.white,
borderRadius:
BorderRadius.circular(12)
),
child:
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
const Text(
"📊 FEATURE ENGINEERING",
style:
TextStyle(
fontWeight:
FontWeight.bold,
fontSize:15
)
),
const Divider(),
featureLine(
"Temp moyenne 1h",
"${features["temp_mean_1h"] ?? 0} °C"
),
featureLine(
"Variation température",
"${features["temp_variation"] ?? 0}"
),
featureLine(
"Humidité combinée",
"${features["humidity_combined"] ?? 0}%"
),
featureLine(
"Stress thermique",
"${features["thermal_stress"] ?? 0}"
),
featureLine(
"Vibration Spike",
"${features["vibration_spike"] ?? 0}"
),
featureLine(
"Score activité",
"${features["activity_score"] ?? 0}"
),
]
)
);
}
// ================= BUILD =================
@override
Widget build(BuildContext context){
return Scaffold(
backgroundColor:
Colors.grey.shade100,
body:
SingleChildScrollView(
padding:
const EdgeInsets.all(10),
child:
Column(
children:[
// ===== RESULTAT IA =====
Container(
padding:
const EdgeInsets.all(12),
decoration:
BoxDecoration(
color:Colors.white,
borderRadius:
BorderRadius.circular(12)
),
child:
Row(
children:[
confidenceCircle(),
const SizedBox(width:15),
Expanded(
child:
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children:[
Text(
!analyzed
?
"Analyse IA non lancée"
:
extraction=="favorable"
?
"Extraction possible"
:
"Extraction déconseillée",
style:
TextStyle(
fontSize:18,
fontWeight:
FontWeight.bold,
color:
!analyzed
?
Colors.orange
:
extraction=="favorable"
?
Colors.green
:
Colors.red
)
),
const SizedBox(height:5),
Text(
"Confiance IA : ${confidence.toInt()} %",
style:
const TextStyle(
fontSize:14
)
)
]
)
)
]
)
),
const SizedBox(height:10),
stateBox(),
const SizedBox(height:10),
GridView.count(
crossAxisCount:2,
crossAxisSpacing:8,
mainAxisSpacing:8,
childAspectRatio:2.4,
shrinkWrap:true,
physics:
const NeverScrollableScrollPhysics(),
children:[
sensorCard(
"Température",
"${sensor["temperature"] ?? 0} °C",
Icons.thermostat,
Colors.red
),
sensorCard(
"Humidité",
"${sensor["humidity"] ?? 0} %",
Icons.water_drop,
Colors.blue
),
sensorCard(
"Poids",
"${sensor["weight"] ?? 0} g",
Icons.scale,
Colors.green
),
sensorCard(
"Vibration",
"${sensor["vibration"] ?? 0}",
Icons.vibration,
Colors.orange
),
]
),
const SizedBox(height:10),
featureBox(),
const SizedBox(height:15),
// ===== BUTTON IA =====
SizedBox(
width:double.infinity,
height:45,
child:
ElevatedButton(
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.blue
),
onPressed:
runAI,
child:
const Text(
"LANCER ANALYSE IA",
style:
TextStyle(
color:Colors.white,
fontWeight:
FontWeight.bold
)
)
)
),
const SizedBox(height:15),
// ===== START STOP =====
Row(
mainAxisAlignment:
MainAxisAlignment.center,
children:[
ElevatedButton.icon(
icon:
const Icon(Icons.play_arrow),
label:
const Text("START"),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.green,
foregroundColor:
Colors.white
),
onPressed:
() async{
bool result =
await ControlService.startExtraction();
setState((){
running=result;
});
}
),
const SizedBox(width:15),
ElevatedButton.icon(
icon:
const Icon(Icons.stop),
label:
const Text("STOP"),
style:
ElevatedButton.styleFrom(
backgroundColor:
Colors.red,
foregroundColor:
Colors.white
),
onPressed:
() async{
bool result =
await ControlService.stopExtraction();
setState((){
running=!result;
});
}
)
]
),
const SizedBox(height:10),
Text(
running
?
"🟢 Extraction en cours"
:
"🔴 Extraction arrêtée",
style:
TextStyle(
fontSize:16,
fontWeight:
FontWeight.bold,
color:
running
?
Colors.green
:
Colors.red
)
)
]
)
)
);
}
}