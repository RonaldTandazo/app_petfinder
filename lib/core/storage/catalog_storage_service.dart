import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CatalogStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kPetCatalogs = 'pet_catalogs_cache';
  static const String _kAccountCatalogs = 'account_catalogs_cache';
  static const String _kPostingCatalogs = 'posting_catalogs_cache';

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

  static Future<void> saveAccountCatalogs(Map<String, dynamic> data) async {
    await _storage.write(key: _kAccountCatalogs, value: jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getAccountCatalogs() async {
    final rawData = await _storage.read(key: _kAccountCatalogs);
    if (rawData == null) return null;

    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePostingCatalogs(Map<String, dynamic> data) async {
    await _storage.write(key: _kPostingCatalogs, value: jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getPostingCatalogs() async {
    final rawData = await _storage.read(key: _kPostingCatalogs);
    if (rawData == null) return null;

    try {
      return jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearCatalogs() async {
    await _storage.delete(key: _kPetCatalogs);
    await _storage.delete(key: _kAccountCatalogs);
    await _storage.delete(key: _kPostingCatalogs);
  }
}