import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('cs_CZ');
  runApp(const CycleCalendarApp());
}

class CycleCalendarApp extends StatelessWidget {
  const CycleCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feel & Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _periodStart;
  DateTime? _periodEnd;

  void _setStart() {
    setState(() {
      _periodStart = _selectedDay;
      _periodEnd = null;
    });
  }

  void _setEnd() {
    final day = _selectedDay!;
    final start = _periodStart;
    if (start == null) {
      _showMessage('Nejdřív označte začátek menstruace.');
      return;
    }
    if (day.isBefore(start)) {
      _showMessage('Konec nemůže být dřív než začátek.');
      return;
    }
    setState(() {
      _periodEnd = day;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daySelected = _selectedDay != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Feel & Flow 🌸')),
      body: Column(
        children: [
          TableCalendar(
            locale: 'cs_CZ',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            rangeStartDay: _periodStart,
            rangeEndDay: _periodEnd,
            calendarStyle: CalendarStyle(
              rangeHighlightColor: Colors.pink.shade100,
              rangeStartDecoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                onPressed: daySelected ? _setStart : null,
                child: const Text('Začátek'),
              ),
              OutlinedButton(
                onPressed: daySelected ? _setEnd : null,
                child: const Text('Konec'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
