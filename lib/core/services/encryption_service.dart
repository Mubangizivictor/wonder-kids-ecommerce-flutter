import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:math';

class EncryptionService {
  static const String _keyName = 'hive_encryption_key';

  static Future<Uint8List> getEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    final keyString = prefs.getString(_keyName);

    if (keyString == null) {
      final key = Hive.generateSecureKey();
      await prefs.setString(_keyName, base64UrlEncode(key));
      return Uint8List.fromList(key);
    } else {
      return base64Url.decode(keyString);
    }
  }
}
