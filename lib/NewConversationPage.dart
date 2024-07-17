import 'package:chatterbox/DatabaseManager.dart';
import 'package:chatterbox/MessagePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewConversationPage extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();

  void _startConversation(BuildContext context) {
    final phoneNumber = phoneNumberController.text;
    if (phoneNumber.isNotEmpty) {
      DatabaseManager.addConversation(DatabaseManager.currentUserId!, phoneNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(conversationId: phoneNumber),
        ),
      );
    } else {
      // TODO: show an error message or prompt user to enter a valid phone number
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Conversation'),
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    TextField(
    controller: phoneNumberController,
    decoration: InputDecoration(
    labelText: 'Enter phone number',
    border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.phone,
    ),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: () => _startConversation(context),
    child: Text('Start Conversation'),
    ),
    ])));
  }
}
