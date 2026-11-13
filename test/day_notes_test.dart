import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cycle_calendar/day_notes_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-03 Nálada a příznaky', () {
    test('Záznam dne se uloží a znovu načte', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final storage = DayNotesStorage();
      await storage.save({
        '2026-11-13': const DayEntry(mood: 3, symptoms: {'Únava'}),
      });

      final loaded = await storage.load();
      expect(loaded['2026-11-13']?.mood, 3);
      expect(loaded['2026-11-13']?.symptoms, contains('Únava'));
    });

    test('Poškozená data aplikaci neshodí', () async {
      FlutterSecureStorage.setMockInitialValues(
          {'day_notes': 'tohle není JSON'});
      final loaded = await DayNotesStorage().load();
      expect(loaded, isEmpty);
    });

    test('Neplatné hodnoty z úložiště se zahodí', () async {
      FlutterSecureStorage.setMockInitialValues({
        'day_notes':
            '{"2026-11-13": {"mood": 99, "symptoms": ["<script>", "Únava"]}}',
      });
      final loaded = await DayNotesStorage().load();
      expect(loaded['2026-11-13']?.mood, isNull);
      expect(loaded['2026-11-13']?.symptoms, {'Únava'});
    });

    test('Klíč dne má formát RRRR-MM-DD', () {
      expect(dayKey(DateTime.utc(2026, 3, 5)), '2026-03-05');
    });
  });
}
