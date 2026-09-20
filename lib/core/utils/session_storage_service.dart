import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorageService {
  static const _storage = FlutterSecureStorage();

  static const String _kMainId = 'main_id';
  static const String _kTutorId = 'tutor_id';
  static const String _kName = 'name';
  static const String _kEmail = 'email';
  static const String _kAvatar = 'avatar';
  static const String _kIsShelter = 'is_shelter';
  static const String _kIsUser = 'is_user';

  static int? mainId;
  static int? tutorId;
  static String? name;
  static String? email;
  static Map<String, dynamic>? avatar;
  static bool isShelter = false;
  static bool isUser = false;

  static Future<void> saveSession(Map<String, dynamic> userData) async {
    mainId = userData['main_id'] as int?;
    tutorId = userData['tutor_id'] as int?;
    name = userData['name'] as String?;
    email = userData['email'] as String?;
    avatar = userData['avatar'] as Map<String, dynamic>?;
    isShelter = (userData['is_shelter'] as bool?) ?? false;
    isUser = (userData['is_user'] as bool?) ?? false;

    await Future.wait([
      if (mainId != null) _storage.write(key: _kMainId, value: mainId.toString()),
      if (tutorId != null) _storage.write(key: _kTutorId, value: tutorId.toString()),
      if (name != null) _storage.write(key: _kName, value: name!),
      if (email != null) _storage.write(key: _kEmail, value: email!),
      if (avatar != null) _storage.write(key: _kAvatar, value: jsonEncode(avatar!)),
      _storage.write(key: _kIsShelter, value: isShelter.toString()),
      _storage.write(key: _kIsUser, value: isUser.toString()),
    ]);
  }

  static Future<void> updateSession(Map<String, dynamic> userData) async {
    name = userData['name'] as String?;
    email = userData['email'] as String?;
    avatar = userData['avatar'] as Map<String, dynamic>?;

    await Future.wait([
      if (name != null) _storage.write(key: _kName, value: name!),
      if (email != null) _storage.write(key: _kEmail, value: email!),
      if (avatar != null) _storage.write(key: _kAvatar, value: jsonEncode(avatar!)),
    ]);
  }

  static Future<void> loadSession() async {
    final String? mId = await _storage.read(key: _kMainId);
    final String? tId = await _storage.read(key: _kTutorId);
    final String? uName = await _storage.read(key: _kName);
    final String? uEmail = await _storage.read(key: _kEmail);
    final String? uAvatar = await _storage.read(key: _kAvatar);
    final String? shelter = await _storage.read(key: _kIsShelter);
    final String? user = await _storage.read(key: _kIsUser);

    mainId = mId != null ? int.tryParse(mId) : null;
    tutorId = tId != null ? int.tryParse(tId) : null;
    name = uName;
    email = uEmail;
    avatar = uAvatar != null ? jsonDecode(uAvatar) as Map<String, dynamic> : null;
    isShelter = shelter == 'true';
    isUser = user == 'true';
  }

  static Future<void> clearSession() async {
    mainId = null;
    tutorId = null;
    name = null;
    email = null;
    avatar = null;
    isShelter = false;
    isUser = false;

    await Future.wait([
      _storage.delete(key: _kMainId),
      _storage.delete(key: _kTutorId),
      _storage.delete(key: _kName),
      _storage.delete(key: _kEmail),
      _storage.delete(key: _kAvatar),
      _storage.delete(key: _kIsShelter),
      _storage.delete(key: _kIsUser),
    ]);
  }
}