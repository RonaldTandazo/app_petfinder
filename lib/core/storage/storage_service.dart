import 'package:app_petfinder/core/storage/account_storage_service.dart';
import 'package:app_petfinder/core/storage/catalog_storage_service.dart';
import 'package:app_petfinder/core/storage/session_storage_service.dart';
import 'package:app_petfinder/core/storage/token_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static void cleanSessionStorage() async {
    await TokenStorageService.deleteToken();
    await SessionStorageService.clearSession();
    await CatalogStorageService.clearCatalogs();
    await AccountStorageService.clearAccount();
  }

  static Future<void> cleanAll() async {
    _storage.deleteAll();
  }
}