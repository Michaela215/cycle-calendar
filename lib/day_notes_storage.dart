import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const moods = ['😣', '🙁', '😐', '🙂', '😄'];

const symptomOptions = [
  'Bolest břicha',
  'Bolest hlavy',
  'Únava',
  'Nadýmání',
  'Akné',
  'Citlivá prsa',
];

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class DayEntry {
  final int? mood;
  final Set<String> symptoms;

  const DayEntry({this.mood, this.symptoms = const {}});

  bool get isEmpty => mood == null && symptoms.isEmpty;

  Map<String, dynamic> toJson() =>
      {'mood': mood, 'symptoms': symptoms.toList()};

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    final m = json['mood'];
    final rawSymptoms = json['symptoms'] as List? ?? [];
    return DayEntry(
      mood: (m is int && m >= 0 && m < moods.length) ? m : null,
      symptoms: {
        for (final s in rawSymptoms)
          if (s is String && symptomOptions.contains(s)) s,
      },
    );
  }
}

class DayNotesStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'day_notes';

  Future<Map<String, DayEntry>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) =>
          MapEntry(key, DayEntry.fromJson(value as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, DayEntry> notes) async {
    final data = notes.map((key, value) => MapEntry(key, value.toJson()));
    await _storage.write(key: _key, value: jsonEncode(data));
  }
}
