import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() =>
      _ChatbotScreenState();
}
class _ChatbotScreenState extends State<ChatbotScreen>{
  final TextEditingController controller =
      TextEditingController();
  final ScrollController scrollController =
      ScrollController();
  List<Map<String,String>> messages = [];
  bool loading = false;
  @override
  void dispose(){
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
  Future<void> send() async {
    String msg =
        controller.text.trim();
    if(msg.isEmpty) return;
    setState((){
      messages.insert(
        0,
        {
          "sender":"user",
          "text":msg
        },
      );
      controller.clear();
      loading=true;
    });
    scrollDown();
    try{
      String response =
          await ChatbotService.sendMessage(msg);
      setState((){
        messages.insert(
          0,
          {
            "sender":"bot",
            "text":response
          },
        );
        loading=false;
      });
    }
    catch(e){
      setState((){
        messages.insert(
          0,
          {
            "sender":"bot",
            "text":
            "Erreur serveur"
          },
        );
        loading=false;
      });
    }
    scrollDown();
  }
  void scrollDown(){
    Future.delayed(
      const Duration(milliseconds:300),
          (){
        if(scrollController.hasClients){
          scrollController.animateTo(
            0,
            duration:
            const Duration(
                milliseconds:400
            ),
            curve:
            Curves.easeOut,
          );
        }
      },
    );
  }
  Widget bubble(
      Map<String,String> message
      ){
    bool user =
        message["sender"]=="user";
    return Align(
      alignment:
      user
          ?
      Alignment.centerRight
          :
      Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.symmetric(
          horizontal:15,
          vertical:8,
        ),
        padding:
        const EdgeInsets.all(14),
        constraints:
        const BoxConstraints(
          maxWidth:300,
        ),
        decoration:
        BoxDecoration(
          color:
          user
              ?
          Colors.blueAccent
              :
          Colors.grey.shade200,
          borderRadius:
          BorderRadius.circular(15),
        ),
        child: Text(
          message["text"]!,
          style:
          TextStyle(
            color:
            user
                ?
            Colors.white
                :
            Colors.black,
            fontSize:16,
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:
      Column(
        children:[
          Expanded(
            child:
            messages.isEmpty
                ?
            Center(
              child:
              Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children:[
                  const Icon(
                    Icons.smart_toy,
                    size:70,
                    color:
                    Colors.blueAccent,
                  ),
                  const SizedBox(
                      height:20
                  ),
                  const Text(
                    "Bonjour 👋",
                    style:
                    TextStyle(
                      fontSize:25,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height:10
                  ),
                  Text(
                    "Comment puis-je vous aider ?",
                    style:
                    TextStyle(
                      fontSize:16,
                      color:
                      Colors.grey.shade600,
                    ),
                  )
                ],
              ),
            )
                :
            Scrollbar(
              controller:
              scrollController,
              thumbVisibility:true,
              thickness:8,
              radius:
              const Radius.circular(10),
              child:
              ListView.builder(
                reverse:true,
                controller:
                scrollController,
                itemCount:
                messages.length +
                    (loading ? 1:0),
                itemBuilder:
                    (context,index){
                  if(index==messages.length){
                    return const Padding(
                      padding:
                      EdgeInsets.all(15),
                      child:
                      Text(
                        "Bot écrit...",
                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontStyle:
                          FontStyle.italic,
                        ),
                      ),
                    );
                  }
                  return bubble(
                      messages[index]
                  );
                },
              ),
            ),
          ),
          Container(
            padding:
            const EdgeInsets.all(10),
            child:
            Row(
              children:[
                Expanded(
                  child:
                  TextField(
                    controller:
                    controller,
                    decoration:
                    InputDecoration(
                      hintText:
                      "Ecrire message...",
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                    ),
                    onSubmitted:
                        (value){
                      send();
                    },
                  ),
                ),
                const SizedBox(
                    width:8
                ),
                FloatingActionButton(
                  backgroundColor:
                  Colors.blueAccent,
                  child:
                  const Icon(
                      Icons.send
                  ),
                  onPressed:
                  send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}