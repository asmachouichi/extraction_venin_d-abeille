import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExtractionButtons extends StatefulWidget {
  const ExtractionButtons({super.key});

  @override
  State<ExtractionButtons> createState() => _ExtractionButtonsState();
}

class _ExtractionButtonsState extends State<ExtractionButtons> {
  bool isExtracting = false;
  int? extractionId;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Démarrer l'extraction
  Future<void> startExtraction() async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/extraction/start"),
      headers: {
        "Authorization": "Bearer ${prefs.getString('token')}",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isExtracting = true;
        extractionId = data["extraction_id"];
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Extraction démarrée")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur démarrage")));
    }
  }

  // Arrêter l'extraction
  Future<void> stopExtraction() async {
    if (extractionId == null) return;

    double finalQuantity = await _askQuantityDialog(); // Demande la quantité réelle

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/extraction/stop"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${prefs.getString('token')}",
      },
      body: jsonEncode({
        "extraction_id": extractionId,
        "quantity": finalQuantity,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isExtracting = false;
        extractionId = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Extraction arrêtée")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur arrêt")));
    }
  }

  // Dialog pour demander la quantité finale
  Future<double> _askQuantityDialog() async {
    TextEditingController controller = TextEditingController();
    double quantity = 0.0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quantité finale de venin (mg)"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Entrer la quantité"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              quantity = double.tryParse(controller.text) ?? 0.0;
              Navigator.pop(context);
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );

    return quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: isExtracting ? null : startExtraction,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
      child: const Text("Démarrer"),
    ),
    const SizedBox(width: 20),
    ElevatedButton(
      onPressed: isExtracting ? () => stopExtraction() : null, // Remplacer 3.5 par la vraie quantité
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
      child: const Text("Arrêter"),
    ),
  ],
);
  }
}