import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'user_name';
  static final _allowed = RegExp(r"^[\p{L} \-']{1,30}$", unicode: true);

  static bool isValidName(String name) => _allowed.hasMatch(name);

  /// null = ještě se neptala, '' = přeskočila nebo smazala
  Future<String?> loadName() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    return isValidName(value) ? value : '';
  }

  Future<void> saveName(String name) =>
      _storage.write(key: _key, value: name);
}
