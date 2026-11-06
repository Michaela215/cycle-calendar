const int defaultCycleLength = 28;

DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) =>
    DateTime.utc(d.year, d.month, d.day + days);

DateTime nextPeriodStart(DateTime lastStart,
        {int cycleLength = defaultCycleLength}) =>
    addDays(lastStart, cycleLength);

DateTime ovulationDay(DateTime lastStart,
        {int cycleLength = defaultCycleLength}) =>
    addDays(lastStart, cycleLength - 14);

bool isFertileDay(DateTime day, DateTime lastStart,
    {int cycleLength = defaultCycleLength}) {
  final ovulation = ovulationDay(lastStart, cycleLength: cycleLength);
  final d = dateOnly(day);
  return !d.isBefore(addDays(ovulation, -5)) &&
      !d.isAfter(addDays(ovulation, 1));
}
bool isPeakFertileDay(DateTime day, DateTime lastStart,
    {int cycleLength = defaultCycleLength}) {
  final ovulation = ovulationDay(lastStart, cycleLength: cycleLength);
  final d = dateOnly(day);
  return !d.isBefore(addDays(ovulation, -2)) && !d.isAfter(ovulation);
}