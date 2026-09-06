import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CatalogStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _kPetCatalogs = 'pet_catalogs_cache';

  static Future<void> savePetCatalogs(Map<String, dynamic> data) async {
    await _storage.write(key: _kPetCatalogs, value: jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getPetCatalogs() async {
    final rawData = await _storage.read(key: _kPetCatalogs);
    if (rawData == null) return null;

    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCatalogs() async {
    await _storage.delete(key: _kPetCatalogs);
  }
}