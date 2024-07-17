import 'package:chatterbox/DatabaseManager.dart';
import 'package:chatterbox/MessagePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddContactPage extends StatelessWidget {
  String contactPhone;
  final TextEditingController contactNameController = TextEditingController();

  AddContactPage({required this.contactPhone});

  void _returnToConversation(BuildContext context) async {
    final contactName = contactNameController.text;
    if (contactName.isNotEmpty) {
    DatabaseManager.addContact(contactPhone, contactName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(conversationId: contactPhone),
        ),
      );
    } else {
      // TODO: show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Contact for $contactPhone'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Contact Name',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _returnToConversation(context),
                    child: const Text('Add Contact'),
                  ),
                ])));
  }
}