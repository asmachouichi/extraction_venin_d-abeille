import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> extractions = [];

  bool loading = true;

  String? errorMessage;

  final String baseUrl = "http://10.0.2.2:5000";

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ============================================================
  // CHARGER L'HISTORIQUE
  // ============================================================

  Future<void> loadHistory() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Le nom doit être le même que celui utilisé
      // dans ton code de connexion.
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        setState(() {
          loading = false;
          errorMessage = "Utilisateur non connecté.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/extractions/history"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          extractions = jsonDecode(response.body);
          loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          loading = false;
          errorMessage = "Session expirée. Veuillez vous reconnecter.";
        });
      } else {
        setState(() {
          loading = false;
          errorMessage =
              "Erreur serveur : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = "Impossible de contacter le serveur.";
      });
    }
  }

  // ============================================================
  // AFFICHER UNE EXTRACTION
  // ============================================================

  Widget buildExtractionCard(dynamic extraction) {
    final id = extraction["id"];
    final quantity = extraction["quantity"];
    final date = extraction["extraction_date"];
    final status = extraction["status"];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ID
          Text(
            "Extraction #$id",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // DATE
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Colors.blueAccent,
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "Date : $date",

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // QUANTITE
          Row(
            children: [
              const Icon(
                Icons.scale,
                color: Colors.orange,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                "Quantité : $quantity g",

                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // STATUT
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.green,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                "Statut : $status",

                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),

        title: const Text(
          "Historique des extractions",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),

            onPressed: loadHistory,
          ),
        ],
      ),

      body: loading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : errorMessage != null

              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 55,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          errorMessage!,

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: loadHistory,

                          child: const Text(
                            "Réessayer",
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              : extractions.isEmpty

                  ? const Center(
                      child: Text(
                        "Aucune extraction disponible",

                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    )

                  : RefreshIndicator(
                      onRefresh: loadHistory,

                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),

                        itemCount: extractions.length,

                        itemBuilder: (context, index) {
                          return buildExtractionCard(
                            extractions[index],
                          );
                        },
                      ),
                    ),
    );
  }
}