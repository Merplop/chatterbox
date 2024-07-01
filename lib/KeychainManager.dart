import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Platform;

class KeychainManager {
  static const storage = FlutterSecureStorage();

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/chatterbox-private-key.txt');
  }

  static Future<File> writePrivateKeyToFile(String privateKey) async {
    final file = await _localFile;

    return file.writeAsString('$privateKey');
  }

  static Future<String> readPrivateKeyFromFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<void> addKey(String keyToAdd, String user) async {
    if (Platform.isWindows) {
      await writePrivateKeyToFile(keyToAdd);
    } else if (Platform.isAndroid) {
    //  await storage.write(key: '$user privateKey', value: keyToAdd);
      await writePrivateKeyToFile(keyToAdd);
    }

  }

  static Future<String> getKey() async {
    if (Platform.isWindows) {
      return await readPrivateKeyFromFile();
    } else if (Platform.isAndroid) {
     // var result = await storage.read(key: 'privateKey');
     // return result!;
      return await readPrivateKeyFromFile();
    }
    return "";
  }
}