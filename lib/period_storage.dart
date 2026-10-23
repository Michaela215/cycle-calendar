import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PeriodStorage {
  static const _storage = FlutterSecureStorage();
  static const _startKey = 'period_start';
  static const _endKey = 'period_end';

  Future<DateTime?> loadStart() => _read(_startKey);
  Future<DateTime?> loadEnd() => _read(_endKey);

  Future<void> save(DateTime? start, DateTime? end) async {
    await _write(_startKey, start);
    await _write(_endKey, end);
  }

  Future<DateTime?> _read(String key) async {
    final value = await _storage.read(key: key);
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> _write(String key, DateTime? date) async {
    if (date == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: date.toIso8601String());
    }
  }
}