import 'package:chatterbox/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';

  void handleButtonPress() async {
    print(passwordController.text);
    print(confirmPasswordController.text);
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
    } else {
      DatabaseManager.registerUser(nameController.text, phoneController.text, passwordController.text);
      Navigator.pushReplacementNamed(context, '/homepage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              cursorColor: const Color(0xFF88C0D0),
              style: const TextStyle(color: Color(0xFF88C0D0)),
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF81A1C1)),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              cursorColor: const Color(0xFF88C0D0),
              style: const TextStyle(color: Color(0xFF88C0D0)),
              controller: phoneController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Color(0xFF81A1C1)),
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: const Color(0xFF88C0D0),
              style: const TextStyle(color: Color(0xFF88C0D0)),
              controller: passwordController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Color(0xFF81A1C1)),
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: const Color(0xFF88C0D0),
              style: const TextStyle(color: Color(0xFF88C0D0)),
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Color(0xFF81A1C1)),
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                handleButtonPress();
              },
              child: Text('Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81A1C1), // Button color from Nord palette
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}