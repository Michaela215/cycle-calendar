import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:cycle_calendar/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('cs_CZ');
  });

  testWidgets('Aplikace zobrazí název Feel & Flow', (tester) async {
    await tester.pumpWidget(const CycleCalendarApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Feel & Flow'), findsOneWidget);
  });

  testWidgets('Na hlavní obrazovce je kalendář', (tester) async {
    await tester.pumpWidget(const CycleCalendarApp());
    await tester.pumpAndSettle();

    expect(find.byType(TableCalendar), findsOneWidget);
  });

  testWidgets('Kalendář ukazuje aktuální měsíc česky', (tester) async {
    await tester.pumpWidget(const CycleCalendarApp());
    await tester.pumpAndSettle();

    final aktualniMesic =
        DateFormat.yMMMM('cs_CZ').format(DateTime.now());
    expect(find.text(aktualniMesic), findsOneWidget);
  });
}
