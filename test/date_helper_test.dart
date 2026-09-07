import 'package:flutter_test/flutter_test.dart';
import 'package:masarefy/core/utils/date_helper.dart';

void main() {
  group('DateHelper.weeksInMonth', () {
    test('splits September 2026 into weeks that together cover every day exactly once', () {
      final month = DateTime(2026, 9);
      final weeks = DateHelper.weeksInMonth(month);

      final allDays = weeks.expand((w) => w.days).toList();
      expect(allDays.length, 30); // September has 30 days.
      expect(allDays.first, DateTime(2026, 9, 1));
      expect(allDays.last, DateTime(2026, 9, 30));

      // No day appears twice, and days are in order.
      for (var i = 1; i < allDays.length; i++) {
        expect(allDays[i].difference(allDays[i - 1]).inDays, 1);
      }
    });

    test('every week (except possibly the first/last) has 7 days', () {
      final weeks = DateHelper.weeksInMonth(DateTime(2026, 9));
      for (var i = 1; i < weeks.length - 1; i++) {
        expect(weeks[i].days.length, 7);
      }
    });

    test('week ids are stable and month-scoped', () {
      final month = DateTime(2026, 9);
      final weeks = DateHelper.weeksInMonth(month);
      expect(weeks.first.idFor(month), '2026-09-W1');
    });
  });

  group('DateHelper.weekContaining', () {
    test('finds the correct week for a given day', () {
      final day = DateTime(2026, 9, 15);
      final week = DateHelper.weekContaining(day);
      expect(week.days.any((d) => DateHelper.isSameDay(d, day)), isTrue);
    });
  });

  group('DateHelper.monthKey / monthLabel', () {
    test('formats consistently', () {
      expect(DateHelper.monthKey(DateTime(2026, 9, 7)), '2026-09');
      expect(DateHelper.monthLabel(DateTime(2026, 9, 7)), 'September 2026');
    });
  });
}
