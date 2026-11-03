import 'package:app_petfinder/core/storage/account_storage_service.dart';
import 'package:app_petfinder/core/storage/catalog_storage_service.dart';
import 'package:app_petfinder/core/storage/session_storage_service.dart';
import 'package:app_petfinder/core/storage/token_storage_service.dart';

class StorageService {

  static void cleanSessionStorage() async {
    await TokenStorageService.deleteToken();
    await SessionStorageService.clearSession();
    await CatalogStorageService.clearCatalogs();
    await AccountStorageService.clearAccount();
  }
}