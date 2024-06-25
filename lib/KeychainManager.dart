import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeychainManager {
  static const storage = FlutterSecureStorage();

  static Future<void> addKey(String keyToAdd, String user) async {
    await storage.write(key: 'privateKey', value: "$user: $keyToAdd");
  }

  static Future<String> getKey() async {
    var result = await storage.read(key: 'privateKey');
    return result!;
  }
}