import 'package:chatterbox/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // Mock conversation data
  final List<Map<String, String>> conversations = [
    DatabaseManager.get_conversation_list();
    {'name': 'Alice', 'lastMessage': 'Hey, how are you?'},
    {'name': 'Bob', 'lastMessage': 'Are you coming to the party?'},
    {'name': 'Charlie', 'lastMessage': 'Let\'s catch up soon!'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            title: Text(conversation['name']!),
            subtitle: Text(conversation['lastMessage']!),
            onTap: () {
              // Handle conversation tap
            },
          );
        },
      ),
    );
  }
}