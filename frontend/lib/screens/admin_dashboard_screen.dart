import 'package:flutter/material.dart';

class AdminDashboard_screen extends StatelessWidget {
  const AdminDashboard_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: const Center(
        child: Text("Bienvenue Admin", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}