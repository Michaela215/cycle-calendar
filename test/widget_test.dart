import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cycle_calendar/main.dart';

Future<void> spustAplikaci(WidgetTester tester) async {
  await tester.pumpWidget(const CycleCalendarApp());
  await tester.pumpAndSettle();
}

Future<void> klepni(WidgetTester tester, Finder cil) async {
  await tester.tap(cil);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('cs_CZ');
  });
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });
  group('Hlavní obrazovka', () {
    testWidgets('Aplikace zobrazí název Feel & Flow', (tester) async {
      await spustAplikaci(tester);
      expect(find.textContaining('Feel & Flow'), findsOneWidget);
    });

    testWidgets('Na hlavní obrazovce je kalendář', (tester) async {
      await spustAplikaci(tester);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('Kalendář ukazuje aktuální měsíc česky', (tester) async {
      await spustAplikaci(tester);
      final aktualniMesic =
          DateFormat.yMMMM('cs_CZ').format(DateTime.now());
      expect(find.text(aktualniMesic), findsOneWidget);
    });
  });

  group('US-01 Záznam menstruace', () {
    testWidgets('Bez vybraného dne jsou tlačítka neaktivní', (tester) async {
      await spustAplikaci(tester);

      final zacatek = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Začátek'));
      final konec = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Konec'));

      expect(zacatek.onPressed, isNull);
      expect(konec.onPressed, isNull);
    });

    testWidgets('Konec bez začátku zobrazí upozornění', (tester) async {
      await spustAplikaci(tester);

      await klepni(tester, find.text('20'));
      await klepni(tester, find.text('Konec'));

      expect(find.text('Nejdřív označte začátek menstruace.'),
          findsOneWidget);
    });

    testWidgets('Konec nemůže být dřív než začátek', (tester) async {
      await spustAplikaci(tester);

      await klepni(tester, find.text('20'));
      await klepni(tester, find.text('Začátek'));
      await klepni(tester, find.text('16'));
      await klepni(tester, find.text('Konec'));

      expect(find.text('Konec nemůže být dřív než začátek.'),
          findsOneWidget);
    });

    testWidgets('Správné pořadí začátku a konce projde bez chyby',
        (tester) async {
      await spustAplikaci(tester);

      await klepni(tester, find.text('16'));
      await klepni(tester, find.text('Začátek'));
      await klepni(tester, find.text('20'));
      await klepni(tester, find.text('Konec'));

      expect(find.text('Konec nemůže být dřív než začátek.'), findsNothing);
      expect(find.text('Nejdřív označte začátek menstruace.'),
          findsNothing);
    });
  });
}