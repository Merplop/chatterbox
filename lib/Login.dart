import 'package:chatterbox/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void handleLogin() async {
    final returnCode = await DatabaseManager.loginUser(phoneController.text, passwordController.text);
    setState(() {
      if (returnCode == -1) {
        errorMessage = 'Invalid phone number';
      } else if (returnCode == 0) {
        errorMessage = 'Invalid password';
      } else {
        errorMessage = '';
        // Navigate to the next screen on successful login
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
              controller: phoneController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Color(0xFF81A1C1)),
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
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
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text('Login'),
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