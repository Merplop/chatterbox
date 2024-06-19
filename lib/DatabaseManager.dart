import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode

class DatabaseManager {
  static Db? db;
  static const String mongoUri = 'mongodb+srv://mirohaapalainen:05xiHzhyngidFSW7@chattercluster.ljuhfn2.mongodb.net/?retryWrites=true&w=majority&appName=ChatterCluster';
  static DbCollection? usersCollection;
  static String? currentUserId;
  static String? currentUserName;

  static Future<void> connect_to_db() async {
    db = await Db.create(mongoUri);
    await db!.open();
    usersCollection = db?.collection('users');
    print('Connection to MongoDB successful');
  }

  static Future<void> register_user(String name, String phone, String password) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, dynamic> data = {
      'name': name,
      'phonenumber': phone,
      'password': hash_password(password)
    };
    await usersCollection?.insertOne(data);
    await login_user(phone, password);
  }

  static Future<String> get_name() async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    if (currentUserId == null) {
      throw StateError('No user logged in');
    }
    Map<String, dynamic> query = {'phonenumber': currentUserId};
    final user = await usersCollection?.findOne(query);
    if (user == null) {
      throw StateError('No user found from DB');
    }
    return user['name'];
  }

  static String hash_password(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<int> login_user(String phone, String password) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, dynamic> query = {'phonenumber': phone};
    final user = await usersCollection?.findOne(query);
    if (user == null) {
      return -1;    // Return code -1 if invalid phone number
    }
    final hashedInputPassword = hash_password(password);
    if (user['password'] == hashedInputPassword) {
      currentUserId = user['phonenumber'];
      currentUserName = await get_name();
      return 1;   // All good!
    } else {
      return 0;   // Return code 0 if invalid password
    }
  }

  static Future<void> close() async {
    try {
      await db!.close();
    } catch (e) {
      log(e.toString());
    }
  }
}