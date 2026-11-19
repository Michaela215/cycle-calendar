const int defaultCycleLength = 28;

enum FertilityLevel { none, fertile, peak }

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

FertilityLevel fertilityLevel(DateTime day, DateTime lastStart,
    {int cycleLength = defaultCycleLength}) {
  if (isPeakFertileDay(day, lastStart, cycleLength: cycleLength)) {
    return FertilityLevel.peak;
  }
  if (isFertileDay(day, lastStart, cycleLength: cycleLength)) {
    return FertilityLevel.fertile;
  }
  return FertilityLevel.none;
}

String fertilityLabel(FertilityLevel level) => switch (level) {
      FertilityLevel.peak => 'Nejplodnější den – nejvyšší šance otěhotnět',
      FertilityLevel.fertile => 'Plodný den – otěhotnění je možné',
      FertilityLevel.none => '',
    };

