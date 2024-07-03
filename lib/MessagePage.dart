import 'package:chatterbox/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  final String conversationId;

  MessagePage({required this.conversationId});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late var messagesOnStartup;
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessageLoop();
  }

  void _fetchMessages() async {
    final fetchedMessages = await DatabaseManager.getMessages(widget.conversationId);
    fetchedMessages.sort((a, b) {
      var aDate = a['date'];
      var bDate = b['date'];
      return aDate.compareTo(bDate);
    });
    setState(() {
      messages = fetchedMessages;
    });
  }

  Future<void> _fetchMessageLoop() async {
    while (true) {
      _fetchMessages();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _sendMessage() {
    final messageText = messageController.text;
    if (messageText.isNotEmpty) {
      setState(() {
        messages.add({'sender': 'Me', 'message': messageText});
        messageController.clear();
      });
      DatabaseManager.addText(DatabaseManager.currentUserId!, widget.conversationId, messageText);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation with ${widget.conversationId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender'] == DatabaseManager.currentUserId || message['sender'] == 'Me';
                final senderText;
                isMe ? senderText = 'Me' : senderText = message['sender'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF81A1C1) : const Color(0xFF88C0D0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          senderText!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['message']!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
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
    );
  }
}