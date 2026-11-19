import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'day_notes_storage.dart';
import 'fertility.dart';
import 'home_page.dart';
import 'period_storage.dart';
import 'profile_storage.dart';
import 'striped_background.dart';
import 'welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('cs_CZ');
  runApp(const CycleCalendarApp());
}

Color fertilityColor(FertilityLevel level) => switch (level) {
      FertilityLevel.peak => Colors.blue.shade600,
      FertilityLevel.fertile => Colors.lightBlue.shade100,
      FertilityLevel.none => Colors.transparent,
    };

class CycleCalendarApp extends StatelessWidget {
  const CycleCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feel & Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const StartGate(),
    );
  }
}

class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  final _profile = ProfileStorage();
  bool _loading = true;
  bool _editing = false;
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _profile.loadName();
    if (!mounted) return;
    setState(() {
      _name = name;
      _loading = false;
    });
  }

  Future<void> _finish(String name) async {
    await _profile.saveName(name);
    if (!mounted) return;
    setState(() {
      _name = name;
      _editing = false;
    });
  }

  void _openCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CalendarPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const StripedBackground(
        child: Scaffold(backgroundColor: Colors.transparent),
      );
    }

    final name = _name;
    if (name == null || _editing) {
      return WelcomePage(initialName: name ?? '', onDone: _finish);
    }
    return HomePage(
      userName: name,
      onOpenCalendar: _openCalendar,
      onEditName: () => setState(() => _editing = true),
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
  final _notesStorage = DayNotesStorage();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _periodStart;
  DateTime? _periodEnd;
  Map<String, DayEntry> _notes = {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final start = await _storage.loadStart();
    final end = await _storage.loadEnd();
    final notes = await _notesStorage.load();
    if (!mounted) return;
    setState(() {
      _periodStart = start;
      _periodEnd = end;
      _notes = notes;
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
      _showMessage('Nejdřív označ začátek menstruace.');
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

  void _updateEntry(DayEntry entry) {
    final key = dayKey(_selectedDay!);
    setState(() {
      if (entry.isEmpty) {
        _notes.remove(key);
      } else {
        _notes[key] = entry;
      }
    });
    _notesStorage.save(_notes);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _legend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendItem(Colors.pink, 'Menstruace'),
          _legendItem(
            fertilityColor(FertilityLevel.fertile),
            fertilityLabel(FertilityLevel.fertile),
          ),
          _legendItem(
            fertilityColor(FertilityLevel.peak),
            fertilityLabel(FertilityLevel.peak),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pouze orientační, není antikoncepce.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Odhad plodných dnů: $from – $to'),
          Text('Odhad další menstruace: $next'),
        ],
      ),
    );
  }

  Widget _dayDetail() {
    final day = _selectedDay;
    if (day == null) return const SizedBox.shrink();

    final entry = _notes[dayKey(day)] ?? const DayEntry();
    final title = DateFormat('d. M.', 'cs_CZ').format(day);
    final heading = Theme.of(context).textTheme.titleMedium;
    final start = _periodStart;
    final level =
        start == null ? FertilityLevel.none : fertilityLevel(day, start);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          if (level != FertilityLevel.none) ...[
            _legendItem(fertilityColor(level), fertilityLabel(level)),
            const SizedBox(height: 12),
          ],
          Text('Jak se cítíš $title?', style: heading),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < moods.length; i++)
                ChoiceChip(
                  label: Text(moods[i], style: const TextStyle(fontSize: 22)),
                  selected: entry.mood == i,
                  onSelected: (selected) => _updateEntry(
                    DayEntry(
                      mood: selected ? i : null,
                      symptoms: entry.symptoms,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Příznaky', style: heading),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final symptom in symptomOptions)
                FilterChip(
                  label: Text(symptom),
                  selected: entry.symptoms.contains(symptom),
                  onSelected: (selected) {
                    final updated = {...entry.symptoms};
                    if (selected) {
                      updated.add(symptom);
                    } else {
                      updated.remove(symptom);
                    }
                    _updateEntry(
                      DayEntry(mood: entry.mood, symptoms: updated),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daySelected = _selectedDay != null;

    return StripedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Kalendář')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: const Color(0xFFFFD54F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99FFC107),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
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
                  selectedBuilder: (context, day, focusedDay) {
                    final isPeriodEdge = isSameDay(day, _periodStart) ||
                        isSameDay(day, _periodEnd);
                    return Container(
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPeriodEdge ? Colors.pink : null,
                        border: Border.all(
                          color: Colors.pink.shade700,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isPeriodEdge ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final start = _periodStart;
                    if (start == null) return null;
                    final level = fertilityLevel(day, start);
                    if (level == FertilityLevel.none) return null;
                    final peak = level == FertilityLevel.peak;
                    return Tooltip(
                      message: fertilityLabel(level),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fertilityColor(level),
                        ),
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: peak ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, day, events) {
                    final mood = _notes[dayKey(day)]?.mood;
                    if (mood == null) return null;
                    return Positioned(
                      bottom: 2,
                      child: Text(
                        moods[mood],
                        style: const TextStyle(fontSize: 10),
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
              _legend(),
              _fertilityInfo(),
              _dayDetail(),
            ],
          ),
        ),
      ),
    );
  }
}
