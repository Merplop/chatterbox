import 'package:fast_rsa/fast_rsa.dart' as fastRsa;
import 'dart:math';

class EncryptionUtil {

  /// Useful for generating random public and private keys.
  static String getRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  /// Encrypts a message using the RSA algorithm
  static Future<String> encryptRSA({required message, required publicKey}) async => await fastRsa.RSA
      .encryptOAEP(message, '', fastRsa.Hash.SHA256, publicKey);

  /// Decrypts a message encrypted using the RSA algorithm
  static Future<String> decryptRSA({required message, required privateKey}) async => await fastRsa.RSA.
    decryptOAEP(message, '', fastRsa.Hash.SHA256, privateKey);

  static Future<fastRsa.KeyPair> generateKeypair() async {
    var result = await fastRsa.RSA.generate(2048);
    return result;
  }
}