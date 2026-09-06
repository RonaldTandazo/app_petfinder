import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorageService {
  static const _storage = FlutterSecureStorage();

  static const String _kMainId = 'main_id';
  static const String _kTutorId = 'tutor_id';
  static const String _kIsShelter = 'is_shelter';
  static const String _kIsUser = 'is_user';
  static const String _kName = 'name';
  static const String _kEmail = 'email';

  static int? mainId;
  static int? tutorId;
  static bool isShelter = false;
  static bool isUser = false;
  static String? name;
  static String? email;

  static Future<void> saveSession(Map<String, dynamic> userData) async {
    mainId = userData['main_id'] as int?;
    tutorId = userData['tutor_id'] as int?;
    isShelter = (userData['is_shelter'] as bool?) ?? false;
    isUser = (userData['is_user'] as bool?) ?? false;
    name = userData['name'] as String?;
    email = userData['email'] as String?;

    await Future.wait([
      if (mainId != null) _storage.write(key: _kMainId, value: mainId.toString()),
      if (tutorId != null) _storage.write(key: _kTutorId, value: tutorId.toString()),
      _storage.write(key: _kIsShelter, value: isShelter.toString()),
      _storage.write(key: _kIsUser, value: isUser.toString()),
      if (name != null) _storage.write(key: _kName, value: name!),
      if (email != null) _storage.write(key: _kEmail, value: email!),
    ]);
  }

  static Future<void> loadSession() async {
    final String? mId = await _storage.read(key: _kMainId);
    final String? tId = await _storage.read(key: _kTutorId);
    final String? shelter = await _storage.read(key: _kIsShelter);
    final String? user = await _storage.read(key: _kIsUser);
    final String? uName = await _storage.read(key: _kName);
    final String? uEmail = await _storage.read(key: _kEmail);

    mainId = mId != null ? int.tryParse(mId) : null;
    tutorId = tId != null ? int.tryParse(tId) : null;
    isShelter = shelter == 'true';
    isUser = user == 'true';
    name = uName;
    email = uEmail;
  }

  static Future<void> clearSession() async {
    mainId = null;
    tutorId = null;
    isShelter = false;
    isUser = false;
    name = null;
    email = null;

    await Future.wait([
      _storage.delete(key: _kMainId),
      _storage.delete(key: _kTutorId),
      _storage.delete(key: _kIsShelter),
      _storage.delete(key: _kIsUser),
      _storage.delete(key: _kName),
      _storage.delete(key: _kEmail),
    ]);
  }
}