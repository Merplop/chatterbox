import 'package:chatterbox/DatabaseManager.dart';
import 'package:chatterbox/MessagePage.dart';
import 'package:chatterbox/NewConversationPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  void newConversation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewConversationPage(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => newConversation(context),
          ),
        ],
      ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseManager.getConversationList(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No conversations found.'));
    } else {
      final conversations = snapshot.data!;
      return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
    final conversation = conversations[index];
    return ListTile(
      title: Text(conversation['name']!),
      subtitle: Text(conversation['lastMessage']!),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(
            conversationId: conversation['name'],
          ),
        )
      );
    },
    );
    },
    );
    }
    },
        ),
    );
  }
}