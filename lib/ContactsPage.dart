import 'package:chatterbox/DatabaseManager.dart';
import 'package:chatterbox/MessagePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          automaticallyImplyLeading: false,
          actions: [

          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseManager.getContactsAsList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Welcome to Chatterbox!'));
              } else {
                final contacts = snapshot.data!;
                return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Card(color: const Color(0xFF3B4252), child: ListTile(
                        title: Text(contact['name']!, style: const TextStyle(color: Color(0xFF88C0D0))),
                        subtitle: Text(contact['phone']!, style: const TextStyle(color: Color(0xFF81A1C1))),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagePage(
                                  conversationId: contact['phone']!,
                                  nameToShow: contact['name']!
                                ),
                              )
                          );
                        },
                      )
                      );
                    }); } })); } }