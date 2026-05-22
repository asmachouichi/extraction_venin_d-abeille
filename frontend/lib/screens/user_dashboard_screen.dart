import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signin_screen.dart';
import 'package:login_signup/services/sensor_service.dart';
import 'package:login_signup/services/control_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {

  // ================= USER =================
  String username = "";
  String email = "";

  // ================= STATE =================
  bool isLoading = true;
  String error = "";

  // ================= DATA =================
  List<dynamic> sensors = [];
  List<FlSpot> chartData = [];

  // ================= SENSORS =================
  double weight = 0;
  double temperature = 0;
  double humidity = 0;
  double ax = 0;
  double ay = 0;
  double az = 0;

  // ================= EXTRACTION =================
  bool extractionON = false;

  @override
  void initState() {
    super.initState();
    loadDashboard();

    // AUTO REFRESH
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      await loadDashboard();
      return true;
    });
  }

  // ================= LOAD DATA =================
  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
        error = "";
      });

      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString("username") ?? "";
      email = prefs.getString("email") ?? "";

      sensors = await SensorService.getSensors();
      extractionON = await ControlService.getStatus();

      if (sensors.isNotEmpty) {
        final last = sensors.last;

        weight = double.tryParse(last["weight"].toString()) ?? 0;
        temperature = double.tryParse(last["temperature"].toString()) ?? 0;
        humidity = double.tryParse(last["humidity"].toString()) ?? 0;

        ax = double.tryParse(last["ax"].toString()) ?? 0;
        ay = double.tryParse(last["ay"].toString()) ?? 0;
        az = double.tryParse(last["az"].toString()) ?? 0;
      }

      chartData = sensors.asMap().entries.map((e) {
        return FlSpot(
          e.key.toDouble(),
          double.tryParse(e.value["weight"].toString()) ?? 0,
        );
      }).toList();

    } catch (e) {
      error = "Erreur API : $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  // ================= DATE =================
  String getDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  // ================= CARD =================
  Widget card({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(icon, color: color, size: 35),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CHART =================
  Widget buildChart() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.2),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(error)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bienvenue $username 👋"),
            Text("$email | ${getDate()}",
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
              onPressed: loadDashboard,
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ================= STATUS =================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: extractionON
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    extractionON
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: extractionON
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    extractionON
                        ? "EXTRACTION ACTIVE"
                        : "EXTRACTION STOP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: extractionON
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ================= BUTTONS =================
            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () async {
                      await ControlService.startExtraction();
                      setState(() => extractionON = true);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("START"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () async {
                      await ControlService.stopExtraction();
                      setState(() => extractionON = false);
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text("STOP"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= CARDS =================
            Row(
              children: [
                card(
                    icon: Icons.scale,
                    title: "Poids",
                    value: "$weight kg",
                    color: Colors.blue),
                const SizedBox(width: 10),
                card(
                    icon: Icons.thermostat,
                    title: "Temp",
                    value: "$temperature °C",
                    color: Colors.red),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                card(
                    icon: Icons.water_drop,
                    title: "Humidité",
                    value: "$humidity %",
                    color: Colors.green),
                const SizedBox(width: 10),
                card(
                    icon: Icons.vibration,
                    title: "X",
                    value: "$ax",
                    color: Colors.orange),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "📊 HX711 Weight Data",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            buildChart(),

            const SizedBox(height: 25),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MPU9250",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text("AX: $ax"),
                    Text("AY: $ay"),
                    Text("AZ: $az"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}