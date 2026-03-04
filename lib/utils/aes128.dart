import 'package:encrypt/encrypt.dart';

class AES128 {
  // MUST be 16 chars
  static const _keyString = "YOUR_16_CHAR_KEY";

  static final Key _key = Key.fromUtf8(_keyString);
  static final IV _iv = IV.fromLength(16);

  static String encrypt(String text) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decrypt(String encrypted) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.decrypt64(encrypted, iv: _iv);
  }
}
