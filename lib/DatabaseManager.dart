import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:math';
import 'package:chatterbox/EncryptionUtil.dart';
import 'package:chatterbox/KeychainManager.dart';
import 'package:flutter/widgets.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
//import 'package:encrypt/encrypt.dart' as encrypt; // for end-to-end encryption
//import 'package:pointycastle/asymmetric/api.dart'; // additional asymmetric encryption functionalities
//import 'package:crypto_keys/crypto_keys.dart';
import 'dart:typed_data';
import 'package:fast_rsa/fast_rsa.dart' as fastRsa;
import 'package:web_socket_channel/web_socket_channel.dart';

class DatabaseManager {
  static Db? db;
  static const String mongoUri = 'mongodb+srv://mirohaapalainen:05xiHzhyngidFSW7@chattercluster.ljuhfn2.mongodb.net/?retryWrites=true&w=majority&appName=ChatterCluster';
  static DbCollection? usersCollection;
  static DbCollection? textsCollection;
  static DbCollection? conversationsCollection;
  static DbCollection? keypairsCollection;
  static DbCollection? contactsCollection;
  static String? currentUserId;
  static String? currentUserName;
  static final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8765'));

  static Future<void> connectToDB() async {
    db = await Db.create(mongoUri);
    await db!.open();
    usersCollection = db?.collection('users');
    textsCollection = db?.collection('texts');
    conversationsCollection = db?.collection('conversations');
    keypairsCollection = db?.collection('keypairs');
    contactsCollection = db?.collection('contacts');
    channel.sink.add('BLAH, Testing');
  }

  static Future<List<Map<String, dynamic>>> getContactsAsList() async {
  /*  Map<String, dynamic> query = {'owner': currentUserId};
    final contacts = await contactsCollection?.find(query);
    final streamIterator = StreamIterator(contacts!);
    List<Map<String, dynamic>> result = [];
    while (await streamIterator.moveNext()) {
    //  result[streamIterator.current['contact_phone']] = streamIterator.current['contact_name'];
      result.add({'phone': streamIterator.current['contact_phone'], 'name': streamIterator.current['contact_name']});
    }
    return result; */

    List<Map<String, dynamic>> result = [];
    channel.sink.add('READ, CONTACTS, {owner: $currentUserId}');

    final streamIterator = StreamIterator(channel.stream);

    // Waits for server to send DONE confirmation before parsing request.

    // TODO: Implement time-out feature if server takes too long

    while (await streamIterator.moveNext()) {
      if (streamIterator.current == 'DONE') {
        break;
      }
    }
    while (await streamIterator.moveNext()) {
      //  result[streamIterator.current['contact_phone']] = streamIterator.current['contact_name'];
      result.add({'phone': streamIterator.current['contact_phone'], 'name': streamIterator.current['contact_name']});
    }
    return result;
  }

  static Future<Map<String, String>> getContacts() async {
    Map<String, dynamic> query = {'owner': currentUserId};
    final contacts = await contactsCollection?.find(query);
    final streamIterator = StreamIterator(contacts!);
    Map<String, String> result = {};
    while (await streamIterator.moveNext()) {
      result[streamIterator.current['contact_phone']] = streamIterator.current['contact_name'];
 //     result.add({'phone': streamIterator.current['contact_phone'], 'name': streamIterator.current['contact_name']});
    }
    return result;

   // Map<String, String> result = {};


  }

  static Future<void> addContact(String otherUserPhone, String otherUserName) async {
    Map<String, dynamic> query = {'owner': currentUserId, 'contact_phone': otherUserPhone, 'contact_name': otherUserName};
    await contactsCollection?.insertOne(query);
  }

  static Future<List<Map<String, dynamic>>> getMessages(String otherUser) async {
    List<Map<String, dynamic>> result = [];
    final query1 = {'owner': currentUserId, 'sender': currentUserId, 'receiver': otherUser};
    final messages1 = await textsCollection?.find(query1);
    final query2 = {'owner': currentUserId, 'sender': otherUser, 'receiver': currentUserId};
    final messages2 = await textsCollection?.find(query2);
    final streamIterator1 = StreamIterator(messages1!);
    final streamIterator2 = StreamIterator(messages2!);
    while (await streamIterator1.moveNext()) {
      result.add({'sender': currentUserId!, 'message': await decryptMessage(streamIterator1.current['content']), 'date': streamIterator1.current['date']});
    }
    while (await streamIterator2.moveNext()) {
      result.add({'sender': otherUser, 'message': await decryptMessage(streamIterator2.current['content']), 'date': streamIterator2.current['date']});
    }
    return result;
  }

  static Future<void> addConversation(String u1, String u2) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    await conversationsCollection?.insertOne({'user1': u1, 'user2': u2});
  }

  static Future<void> generateKeypair(String user) async {
    final hashedUser = hashData(user);
    var keyPair = await EncryptionUtil.generateKeypair();
    Map<String, dynamic> query = {'user': hashedUser};
    var response = await keypairsCollection?.findOne(query);
    if (response == null) {
      Map<String, dynamic> docToInsert = {'user': hashedUser, 'publicKey': keyPair.publicKey};
      await keypairsCollection?.insertOne(docToInsert);
    } else {
      await keypairsCollection?.updateOne(
          where.eq('user', hashedUser), modify.set('publicKey', keyPair.publicKey),
      );
    }
    await KeychainManager.addKey(keyPair.privateKey, user);
  }

  static Future<String> encryptMessage(String owner, String data) async {
    final hashedUser = hashData(owner);
    var publicKey;
    Map<String, dynamic> query = {'user': hashedUser};
    var publicKeyResponse = (await keypairsCollection?.findOne(query));
    if (publicKeyResponse == null) {
      var keyPair = await EncryptionUtil.generateKeypair();
      publicKey = keyPair.publicKey;
      Map<String, dynamic> docToInsert = {'user': hashedUser, 'publicKey': keyPair.publicKey, 'privateKey': keyPair.privateKey};
      keypairsCollection?.insertOne(docToInsert);
    } else {
      publicKey = publicKeyResponse['publicKey'];
    }
    return await EncryptionUtil.encryptRSA(message: data, publicKey: publicKey);
  }

  static Future<String> decryptMessage(String data) async {
    var privateKey = await KeychainManager.getKey();
    final hashedUser = hashData(currentUserId!);
    Map<String, dynamic> query = {'user': hashedUser};
//    var privateKey = (await keypairsCollection?.findOne(query))?['privateKey'];
    return await EncryptionUtil.decryptRSA(message: data, privateKey: privateKey);
  }

 static Future<List<Map<String, dynamic>>> getConversationList() async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, String> contactList = await getContacts();
    List<Map<String, dynamic>> result = [];
    List<Map<String, dynamic>> conversationList = await getEncryptedConversationList();
    for (int i = 0; i < conversationList.length; i++) {
      var contactPhone = conversationList[i]['name'];
      var contactName = contactPhone;
      if (contactList[contactPhone] != null) {
        contactName = contactList[contactPhone];
   }
      result.add({'phone-and-name': [contactPhone, contactName], 'lastMessage': await decryptMessage(conversationList[i]['lastMessage'])});
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getEncryptedConversationList() async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, dynamic> query1 = {'user1': currentUserId};
    // Case 1: Fetch all convos from DB in which 'user1' is signed in user
    final convos1 = await conversationsCollection?.find(query1);
    Map<String, dynamic> query2 = {'user2': currentUserId};
    // Case 2: Fetch all convos from DB in which 'user2' is signed in user
    final convos2 = await conversationsCollection?.find(query2);
    List<Map<String, dynamic>> texts = [];
    final streamIterator1 = StreamIterator(convos1!);
    // Adds most recent texts from convos in case 1
    while (await streamIterator1.moveNext()) {
      final currentOtherUser = streamIterator1.current['user2'];
      final messageToAdd;
      final lastMessageSentByUser = await textsCollection?.findOne(
        where
        .eq('owner', currentUserId)
        .eq('sender', currentUserId)
            .eq('receiver', currentOtherUser)
            .sortBy('date', descending: true)
      );
      final lastMessageSentByOther = await textsCollection?.findOne(
        where
            .eq('owner', currentUserId)
        .eq('sender', currentOtherUser)
            .eq('receiver', currentUserId)
            .sortBy('date', descending: true)
      );
      if (lastMessageSentByUser == null && lastMessageSentByOther == null) {
        throw StateError("Something went wrong in case 1");
      } else if (lastMessageSentByUser == null) {
        messageToAdd = lastMessageSentByOther;
      } else if (lastMessageSentByOther == null) {
        messageToAdd = lastMessageSentByUser;
      } else {
        var dateTime1 = lastMessageSentByUser['date'] as DateTime;
        var dateTime2 = lastMessageSentByOther['date'] as DateTime;
        if ( dateTime1.isAfter(dateTime2) ) {
          messageToAdd = lastMessageSentByUser;
        } else {
          messageToAdd = lastMessageSentByOther;
        }
      }
      texts.add({'name': currentOtherUser, 'lastMessage': messageToAdd?['content']});
    }
    final streamIterator2 = StreamIterator(convos2!);
    // Adds most recent texts from convos in case 2
    while (await streamIterator2.moveNext()) {
      final currentOtherUser = streamIterator2.current['user1'];
      final messageToAdd;
      final lastMessageSentByUser = await textsCollection?.findOne(
          where
              .eq('owner', currentUserId)
              .eq('sender', currentUserId)
              .eq('receiver', currentOtherUser)
              .sortBy('date', descending: true)
      );
      final lastMessageSentByOther = await textsCollection?.findOne(
          where
              .eq('owner', currentUserId)
              .eq('sender', currentOtherUser)
              .eq('receiver', currentUserId)
              .sortBy('date', descending: true)
      );
      if (lastMessageSentByUser == null && lastMessageSentByOther == null) {
        throw StateError("Something went wrong in case 2");
      } else if (lastMessageSentByUser == null) {
        messageToAdd = lastMessageSentByOther;
      } else if (lastMessageSentByOther == null) {
        messageToAdd = lastMessageSentByUser;
      } else {
        var dateTime1 = lastMessageSentByUser['date'] as DateTime;
        var dateTime2 = lastMessageSentByOther['date'] as DateTime;
        if ( dateTime1.isAfter(dateTime2) ) {
          messageToAdd = lastMessageSentByUser;
        } else {
          messageToAdd = lastMessageSentByOther;
        }
      }
      texts.add({'name': currentOtherUser, 'lastMessage': messageToAdd?['content']});
    }
    return texts;
  }

  static Future<void> addText(String sender, String receiver, String content) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    var encryptedContentSender = await encryptMessage(sender, content);
    Map<String, dynamic> entry1 = {
      'owner': sender,
      'sender': sender,
      'receiver': receiver,
      'content': encryptedContentSender,
      'date': DateTime.now()
    };
    await textsCollection?.insertOne(entry1);
    var encryptedContentReceiver = await encryptMessage(receiver, content);
    Map<String, dynamic> entry2 = {
      'owner': receiver,
      'sender': sender,
      'receiver': receiver,
      'content': encryptedContentReceiver,
      'date': DateTime.now()
    };
    await textsCollection?.insertOne(entry2);
  }

  static Future<void> registerUser(String name, String phone, String password) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, dynamic> data = {
      'name': name,
      'phonenumber': phone,
      'password': hashData(password)
    };
    await usersCollection?.insertOne(data);
    await generateKeypair(phone);
    await loginUser(phone, password);
  }

  static Future<String> getName() async {
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

  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<int> loginUser(String phone, String password) async {
    if (db == null || !db!.isConnected) {
      throw StateError('Database is not connected');
    }
    Map<String, dynamic> query = {'phonenumber': phone};
    final user = await usersCollection?.findOne(query);
    if (user == null) {
      return -1;    // Return code -1 if invalid phone number
    }
    final hashedInputPassword = hashData(password);
    if (user['password'] == hashedInputPassword) {
      currentUserId = user['phonenumber'];
      currentUserName = await getName();
      return 1;   // All good!
    } else {
      return 0;   // Return code 0 if invalid password
    }
  }

  static Future<void> close() async {
    try {
      await db!.close();
    } catch (e) {
      print(e.toString());
    }
  }
}