import 'package:flutter_test/flutter_test.dart';

import 'package:cycle_calendar/fertility.dart';

void main() {
  final start = DateTime.utc(2026, 10, 1);

  group('US-02 Odhad plodných dnů', () {
    test('Další menstruace začne po 28 dnech', () {
      expect(nextPeriodStart(start), DateTime.utc(2026, 10, 29));
    });

    test('Ovulace je 14 dní před další menstruací', () {
      expect(ovulationDay(start), DateTime.utc(2026, 10, 15));
    });

    test('Plodné okno: hraniční hodnoty', () {
      expect(isFertileDay(DateTime.utc(2026, 10, 9), start), isFalse);
      expect(isFertileDay(DateTime.utc(2026, 10, 10), start), isTrue);
      expect(isFertileDay(DateTime.utc(2026, 10, 16), start), isTrue);
      expect(isFertileDay(DateTime.utc(2026, 10, 17), start), isFalse);
    });

    test('Výpočet funguje i přes přelom roku', () {
      expect(nextPeriodStart(DateTime.utc(2026, 12, 20)),
          DateTime.utc(2027, 1, 17));
    });

    test('Nejplodnější dny: hraniční hodnoty', () {
      expect(isPeakFertileDay(DateTime.utc(2026, 10, 12), start), isFalse);
      expect(isPeakFertileDay(DateTime.utc(2026, 10, 13), start), isTrue);
      expect(isPeakFertileDay(DateTime.utc(2026, 10, 15), start), isTrue);
      expect(isPeakFertileDay(DateTime.utc(2026, 10, 16), start), isFalse);
    });
  });
}
