import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/widgets/custom_line_chart.dart';
import 'package:login_signup/widgets/extraction_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signin_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
      email = prefs.getString("email") ?? "";
    });
  }

  String getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  // Carte personnalisée
  Widget buildDashboardCard({
    required IconData icon,
    required Color color,
    required String title,
    double iconSize = 40,
    double fontSize = 14,
    double padding = 12,
  }) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Méthode pour le graphique
  Widget _chart1() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CustomLineChart(
        data: [
          FlSpot(1, 1),
          FlSpot(2, 2),
          FlSpot(3, 3),
          FlSpot(4, 4),
          FlSpot(5, 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue $username 👋",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Email: $email | Date: ${getCurrentDate()}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                buildDashboardCard(
                  icon: Icons.biotech,
                  color: Colors.blue,
                  title: "Total Extraction",
                  iconSize: 30,
                  fontSize: 14,
                ),
                const SizedBox(width: 10),
                buildDashboardCard(
                  icon: Icons.water_drop,
                  color: Colors.green,
                  title: "Total Venin Collecté",
                  iconSize: 30,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                buildDashboardCard(
                  icon: Icons.access_time,
                  color: Colors.orange,
                  title: "Durée Moyenne",
                  iconSize: 30,
                  fontSize: 14,
                ),
                const SizedBox(width: 10),
                buildDashboardCard(
                  icon: Icons.date_range,
                  color: Colors.purple,
                  title: "Dernière Extraction",
                  iconSize: 30,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const ExtractionButtons(),
            const SizedBox(height: 30),
            _chart1(),
          ],
        ),
      ),
    );
  }
}