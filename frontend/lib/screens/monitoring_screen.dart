import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_model.dart';
import '../services/sensor_service.dart';
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}
class _MonitoringScreenState extends State<MonitoringScreen> {
  List<SensorData> data = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadData();
  }
  Future<void> loadData() async {
    data = await SensorService.loadCsvData();
    setState(() => loading = false);
  }
  // ================= BUILD SPOTS =================
  List<FlSpot> buildSpots(double Function(SensorData d) selector) {
    return List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), selector(data[i])),
    );
  }
  // ================= CARD =================
  Widget buildCard({
    required String title,
    required String value,
    required List<FlSpot> spots,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 8, // 👈 affiche TOUT le dataset
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: data.length.toDouble(),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: color,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (data.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No dataset found")),
      );
    }
    final last = data.last;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1220),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Poids"),
              Tab(text: "Température"),
              Tab(text: "Humidité"),
              Tab(text: "Vibration"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: TabBarView(
            children: [
              // ================= WEIGHT =================
              buildCard(
                title: "Poids (g)",
                value: last.weight.toStringAsFixed(2),
                spots: buildSpots((d) => d.weight),
                color: Colors.orange,
              ),
              // ================= TEMPERATURE =================
              buildCard(
                title: "Température (°C)",
                value: last.temperature.toStringAsFixed(2),
                spots: buildSpots((d) => d.temperature),
                color: Colors.red,
              ),
              // ================= HUMIDITY =================
              buildCard(
                title: "Humidité (%)",
                value: last.humidity.toStringAsFixed(2),
                spots: buildSpots((d) => d.humidity),
                color: Colors.blue,
              ),
              // ================= VIBRATION =================
              buildCard(
                title: "Vibration",
                value: last.vibration.toStringAsFixed(3),
                spots: buildSpots((d) => d.vibration),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}