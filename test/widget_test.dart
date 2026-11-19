import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
    FlutterSecureStorage.setMockInitialValues({'user_name': ''});
  });

  group('Hlavní obrazovka', () {
    testWidgets('Aplikace zobrazí název Feel & Flow', (tester) async {
      await spustAplikaci(tester);
      expect(find.text('Feel & Flow 🌸'), findsOneWidget);
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

      expect(find.text('Nejdřív označ začátek menstruace.'), findsOneWidget);
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
      expect(find.text('Nejdřív označ začátek menstruace.'), findsNothing);
    });
  });

  group('US-04 Oslovení', () {
    testWidgets('Při prvním spuštění se zobrazí uvítací obrazovka',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      await spustAplikaci(tester);

      expect(find.text('Jak tě máme oslovovat?'), findsOneWidget);
    });

    testWidgets('Po zadání jména se zobrazí pozdrav', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      await spustAplikaci(tester);

      await tester.enterText(find.byType(TextField), 'Míšo');
      await klepni(tester, find.text('Pokračovat'));

      expect(find.text('Vítej, Míšo'), findsOneWidget);
    });

    testWidgets('Aplikace si jméno pamatuje', (tester) async {
      FlutterSecureStorage.setMockInitialValues({'user_name': 'Míšo'});
      await spustAplikaci(tester);

      expect(find.text('Vítej, Míšo'), findsOneWidget);
      expect(find.text('Jak tě máme oslovovat?'), findsNothing);
    });

    testWidgets('Přeskočit zobrazí obecný pozdrav', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      await spustAplikaci(tester);

      await klepni(tester, find.text('Přeskočit'));

      expect(find.text('Vítej ve Feel & Flow'), findsOneWidget);
    });

    testWidgets('Prázdné jméno zobrazí upozornění', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      await spustAplikaci(tester);

      await klepni(tester, find.text('Pokračovat'));

      expect(find.textContaining('Napiš, jak tě máme oslovovat'),
          findsOneWidget);
    });

    testWidgets('Nebezpečný vstup se odmítne', (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      await spustAplikaci(tester);

      await tester.enterText(find.byType(TextField), '<script>');
      await klepni(tester, find.text('Pokračovat'));

      expect(find.textContaining('Použij jen písmena'), findsOneWidget);
      expect(find.text('Jak tě máme oslovovat?'), findsOneWidget);
    });
  });
}
5. Nový soubor test/profile_storage_test.dart
dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cycle_calendar/profile_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-04 Validace jména', () {
    test('Allowlist: povolené a zakázané vstupy', () {
      expect(ProfileStorage.isValidName('Míšo'), isTrue);
      expect(ProfileStorage.isValidName('Anna-Marie'), isTrue);
      expect(ProfileStorage.isValidName("O'Neil"), isTrue);
      expect(ProfileStorage.isValidName(''), isFalse);
      expect(ProfileStorage.isValidName('<script>'), isFalse);
      expect(ProfileStorage.isValidName('Míša123'), isFalse);
      expect(ProfileStorage.isValidName('a' * 31), isFalse);
    });

    test('Podvržené jméno v úložišti se nepoužije', () async {
      FlutterSecureStorage.setMockInitialValues({'user_name': '<script>'});
      final name = await ProfileStorage().loadName();
      expect(name, '');
    });
  });
}

