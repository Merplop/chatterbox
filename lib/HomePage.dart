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
        title: const Text('Conversations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              color: const Color(0xFF88C0D0),
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushReplacementNamed(context, '/contacts')
          ),
          IconButton(
          color: const Color(0xFF88C0D0),
            icon: const Icon(Icons.add),
            onPressed: () => newConversation(context),
          ),
          IconButton(
            color: const Color(0xFF88C0D0),
            icon: const Icon(Icons.refresh),
            onPressed: () => Navigator.pushReplacementNamed(context, '/homepage')
          ),
        ],
      ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseManager.getConversationList(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('Welcome to Chatterbox!'));
    } else {
      final conversations = snapshot.data!;
      return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
    final conversation = conversations[index];
    return Card(color: const Color(0xFF3B4252), child: ListTile(
      title: Text(conversation['phone-and-name'][1]!, style: const TextStyle(color: Color(0xFF88C0D0))),
      subtitle: Text(conversation['lastMessage']!, style: const TextStyle(color: Color(0xFF81A1C1))),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagePage(
                conversationId: conversation['phone-and-name'][0]!,
                nameToShow: conversation['phone-and-name'][1]!
              ),
            )
        );
      },
    )
    );
      }); } })); } }
