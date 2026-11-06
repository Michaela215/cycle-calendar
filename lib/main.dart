import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'fertility.dart';
import 'period_storage.dart';

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
  final _storage = PeriodStorage();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _periodStart;
  DateTime? _periodEnd;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final start = await _storage.loadStart();
    final end = await _storage.loadEnd();
    if (!mounted) return;
    setState(() {
      _periodStart = start;
      _periodEnd = end;
    });
  }

  void _setStart() {
    setState(() {
      _periodStart = _selectedDay;
      _periodEnd = null;
    });
    _storage.save(_periodStart, _periodEnd);
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
    _storage.save(_periodStart, _periodEnd);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _fertilityInfo() {
    final start = _periodStart;
    if (start == null) return const SizedBox.shrink();

    final ovulation = ovulationDay(start);
    final format = DateFormat('d. M.', 'cs_CZ');
    final from = format.format(addDays(ovulation, -5));
    final to = format.format(addDays(ovulation, 1));
    final next = format.format(nextPeriodStart(start));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Odhad plodných dnů: $from – $to'),
          Text('Odhad další menstruace: $next'),
          const SizedBox(height: 8),
          const Text(
            'Pouze orientační, není antikoncepce.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daySelected = _selectedDay != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Feel & Flow 🌸')),
      body: SingleChildScrollView(
        child: Column(
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
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: Colors.black87),
                rangeStartDecoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final start = _periodStart;
                  if (start == null || !isFertileDay(day, start)) {
                    return null;
                  }
                  final peak = isPeakFertileDay(day, start);
                  return Container(
                    margin: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: peak
                          ? Colors.blue.shade600
                          : Colors.lightBlue.shade100,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: peak ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
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
            _fertilityInfo(),
          ],
        ),
      ),
    );
  }
}
