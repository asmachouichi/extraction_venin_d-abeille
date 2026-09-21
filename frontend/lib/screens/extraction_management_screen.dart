import 'package:flutter/material.dart';
import '../services/extraction_service.dart';

class ExtractionManagementScreen extends StatefulWidget {
  const ExtractionManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExtractionManagementScreen> createState() =>
      _ExtractionManagementScreenState();
}

class _ExtractionManagementScreenState
    extends State<ExtractionManagementScreen> {

  List<dynamic> extractions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadExtractions();
  }

  Future<void> loadExtractions() async {

    try {

      final data =
      await ExtractionService.getExtractions();

      setState(() {

        extractions = data;

        loading = false;

      });

    }

    catch (e) {

      setState(() {

        loading = false;

      });

      print(e);

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xff08131F),

      appBar: AppBar(

        backgroundColor:
        const Color(0xff16324F),

        title: const Text(

          "Gestion des extractions",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

      body: RefreshIndicator(

        onRefresh: loadExtractions,

        child: loading

            ? const Center(
          child: CircularProgressIndicator(),
        )

            : extractions.isEmpty

            ? const Center(

          child: Text(

            "Aucune extraction",

            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),

          ),

        )

            : ListView.builder(

          padding:
          const EdgeInsets.all(12),

          itemCount:
          extractions.length,

          itemBuilder:
              (context, index) {

            final extraction =
            extractions[index];

            bool running =
                extraction["status"]
                    .toString()
                    .toLowerCase() ==
                    "running";

            return Card(

              color:
              const Color(0xff142536),

              margin:
              const EdgeInsets.only(
                  bottom: 12),

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(15),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(15),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        CircleAvatar(

                          backgroundColor:

                          running
                              ? Colors.green
                              : Colors.red,

                          child: Icon(

                            running
                                ? Icons.play_arrow
                                : Icons.stop,

                            color:
                            Colors.white,

                          ),

                        ),

                        const SizedBox(
                            width: 12),

                        Expanded(

                          child: Text(

                            extraction["username"],

                            style:
                            const TextStyle(

                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,

                              fontSize: 18,

                            ),

                          ),

                        ),

                        Container(

                          padding:
                          const EdgeInsets.symmetric(

                            horizontal: 10,

                            vertical: 5,

                          ),

                          decoration:
                          BoxDecoration(

                            color:

                            running
                                ? Colors.green
                                : Colors.red,

                            borderRadius:
                            BorderRadius.circular(
                                20),

                          ),

                          child: Text(

                            extraction["status"],

                            style:
                            const TextStyle(

                              color:
                              Colors.white,

                            ),

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 20),

                    Row(

                      children: [

                        const Icon(

                          Icons.science,

                          color:
                          Colors.orange,

                        ),

                        const SizedBox(width: 8),

                        Text(

                          "Quantité : ${extraction["quantity"]} g",

                          style:
                          const TextStyle(

                            color:
                            Colors.white,

                            fontSize: 16,

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 10),

                    Row(

                      children: [

                        const Icon(

                          Icons.calendar_month,

                          color:
                          Colors.blue,

                        ),

                        const SizedBox(width: 8),

                        Expanded(

                          child: Text(

                            extraction["date"],

                            style:
                            const TextStyle(

                              color:
                              Colors.white70,

                            ),

                          ),

                        ),

                      ],

                    ),
                                        const SizedBox(height: 10),

                    Row(

                      children: [

                        const Icon(

                          Icons.person,

                          color: Colors.purple,

                        ),

                        const SizedBox(width: 8),


                        Text(

                          "ID Extraction : ${extraction["id"]}",

                          style: const TextStyle(

                            color: Colors.white70,

                          ),

                        ),

                      ],

                    ),


                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }

}