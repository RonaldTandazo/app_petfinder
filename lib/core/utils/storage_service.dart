import 'package:app_petfinder/core/utils/account_storage_service.dart';
import 'package:app_petfinder/core/utils/catalog_storage_service.dart';
import 'package:app_petfinder/core/utils/session_storage_service.dart';
import 'package:app_petfinder/core/utils/token_storage_service.dart';

class StorageService {

  static void cleanSessionStorage() async {
    await TokenStorageService.deleteToken();
    await SessionStorageService.clearSession();
    await CatalogStorageService.clearCatalogs();
    await AccountStorageService.clearAccount();
  }
}