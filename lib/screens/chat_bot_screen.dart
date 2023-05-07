import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findmybag/services/chat_service.dart';
import 'package:findmybag/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class ChatBotScreen extends StatelessWidget {
  static const id = 'chat_bot_screen.dart';
  ChatBotScreen({super.key});

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.addMessage(_messageController.text, 'eu');
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _chatService.messages,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot message = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(message['content']),
                      subtitle: Text(message['senderId']),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        InputDecoration(hintText: 'Digite sua mensagem'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     Expanded(
      //       child: Align(
      //         alignment: Alignment.bottomLeft,
      //         child: GroupedListView<Message, DateTime>(
      //           padding: EdgeInsets.all(8),
      //           reverse: true,
      //           order: GroupedListOrder.DESC,
      //           elements: messages,
      //           groupBy: (message) => DateTime(2023),
      //           groupHeaderBuilder: (Message message) => SizedBox(),
      //           itemBuilder: (context, Message message) => Align(
      //             alignment: message.isSentByMe
      //                 ? Alignment.centerRight
      //                 : Alignment.centerLeft,
      //             child: Card(
      //               color: message.isSentByMe ? Colors.blue : Colors.white,
      //               elevation: 8,
      //               child: Padding(
      //                 padding: EdgeInsets.all(12),
      //                 child: Text(message.text),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Container(
      //       color: Colors.grey.shade300,
      //       child: const TextField(
      //         decoration: InputDecoration(
      //           contentPadding: EdgeInsets.all(12),
      //           hintText: 'Type your message here ',
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
