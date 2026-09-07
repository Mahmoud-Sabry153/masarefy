/// Represents one week inside a specific month, holding only the days of
/// that week that actually fall inside the month (so the first/last week
/// of a month can be shorter than 7 days).
class WeekOfMonth {
  const WeekOfMonth({
    required this.index,
    required this.days,
  });

  /// 1-based position of this week within the month (Week 1, Week 2, ...).
  final int index;

  /// The calendar days of this week that belong to the month, in order.
  final List<DateTime> days;

  DateTime get firstDay => days.first;
  DateTime get lastDay => days.last;

  /// A stable id used as a Hive key, e.g. "2026-09-W1".
  String idFor(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}-W$index';
}

/// Pure, dependency-free date math for splitting a month into weeks and
/// weeks into days. Kept isolated from Flutter/Hive/Provider so it can be
/// unit-tested in plain Dart (see test/date_helper_test.dart) and reused
/// anywhere in the app.
class DateHelper {
  DateHelper._();

  /// Normalizes any [DateTime] to midnight, dropping the time-of-day.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Splits [month] into calendar weeks (Monday-start), returning only the
  /// days that fall within that month for each week.
  static List<WeekOfMonth> weeksInMonth(DateTime month) {
    final first = startOfMonth(month);
    final last = endOfMonth(month);

    final weeks = <WeekOfMonth>[];
    var cursor = first;
    var weekIndex = 1;

    while (!cursor.isAfter(last)) {
      // DateTime.weekday: Monday = 1 ... Sunday = 7.
      final daysUntilSunday = 7 - cursor.weekday;
      var weekEnd = cursor.add(Duration(days: daysUntilSunday));
      if (weekEnd.isAfter(last)) weekEnd = last;

      final days = <DateTime>[];
      var d = cursor;
      while (!d.isAfter(weekEnd)) {
        days.add(d);
        d = d.add(const Duration(days: 1));
      }

      weeks.add(WeekOfMonth(index: weekIndex, days: days));
      weekIndex++;
      cursor = weekEnd.add(const Duration(days: 1));
    }

    return weeks;
  }

  /// Finds which [WeekOfMonth] a given day belongs to, within its own month.
  static WeekOfMonth weekContaining(DateTime day) {
    final weeks = weeksInMonth(day);
    return weeks.firstWhere(
      (w) => w.days.any((d) => isSameDay(d, day)),
      orElse: () => weeks.first,
    );
  }

  static const List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static String monthLabel(DateTime month) =>
      '${monthNames[month.month - 1]} ${month.year}';

  static String monthKey(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
}
