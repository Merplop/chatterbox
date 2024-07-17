import 'package:chatterbox/AddContactPage.dart';
import 'package:chatterbox/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void newContact(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddContactPage(contactPhone: widget.conversationId),
        )
    );
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
        actions: [
          IconButton(
            color: const Color(0xFF88C0D0),
            icon: const Icon(Icons.add),
            onPressed: () => newContact(context),
          ),
        ],
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
                final DateTime time = message['date']!;
                final DateFormat formatter = DateFormat('Hm');
                String formattedTime = formatter.format(time);
                isMe ? senderText = 'Me' : senderText = message['sender'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF81A1C1) : const Color(0xFF88C0D0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          senderText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message['message']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          formattedTime,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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