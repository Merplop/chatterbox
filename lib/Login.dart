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
    final returnCode = await DatabaseManager.login_user(phoneController.text, passwordController.text);
    print("RETURN CODE: " + returnCode.toString());
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
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}