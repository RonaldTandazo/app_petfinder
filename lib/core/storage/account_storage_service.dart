import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kAccount  = 'account';

  static Future<void> saveAccount(Map<String, dynamic> data) async {
    await _storage.write(key: _kAccount, value: jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getAccount() async {
    final rawData = await _storage.read(key: _kAccount);

    if (rawData == null) return null;

    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAccount() async {
    await _storage.delete(key: _kAccount);
  }
}