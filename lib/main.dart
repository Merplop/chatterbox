import 'dart:math';

import 'package:chatterbox/DatabaseManager.dart';
import 'package:chatterbox/HomePage.dart';
import 'package:chatterbox/Register.dart';
import 'package:chatterbox/Login.dart';
import 'package:flutter/material.dart';


void main() async {
  await DatabaseManager.connectToDB();
  runApp(ChatterboxApp());
}

class ChatterboxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatterbox',
      theme: ThemeData(
        primaryColor: const Color(0xFF5E81AC), // Nord10
        hintColor: const Color(0xFF88C0D0), // Nord8
        scaffoldBackgroundColor: const Color(0xFF2E3440), // Nord0
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFD8DEE9)), // Nord4
          bodyMedium: TextStyle(color: Color(0xFFE5E9F0)), // Nord5
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF88C0D0), // Nord8
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
          color: Color(0xFF3B4252), // Nord1
          titleTextStyle: TextStyle(color: Color(0xFFD8DEE9), fontSize: 20), // Nord4
          ),
          iconTheme: IconThemeData(color: Color(0xFFD8DEE9)), // Nord4
        ),
      initialRoute: '/',
      routes: {
        '/': (context) => FrontPage(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/homepage': (context) => HomePage()
      },
    );
  }
}

class FrontPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var subtitles = ['The most secure SMS app ever conceived',
      'No NSA backdoors here',
      'Step aside, iMessage 😎',
      'Look, I would love to steal your data, but I made my app just sooo secure'];
    Random random = new Random();
    var subtitleToShow = subtitles[random.nextInt(subtitles.length)];
    return Scaffold(
      backgroundColor: const Color(0xFF2E3440), // Background color from Nord palette
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Chatterbox',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD8DEE9), // Text color from Nord palette
                ),
              ),
              Text(
                subtitleToShow,
                style: TextStyle(
                    color: Color(0xFF5e81ac),
                    fontSize: 14.0),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81A1C1), // Button color from Nord palette
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF2E3440), // Text color from Nord palette
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF88C0D0), // Button color from Nord palette
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF2E3440), // Text color from Nord palette
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
