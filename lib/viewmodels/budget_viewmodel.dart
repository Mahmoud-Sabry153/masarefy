import 'package:flutter/foundation.dart';
import '../core/utils/date_helper.dart';
import '../data/repositories/budget_repository.dart';

/// ViewModel for the monthly budget and its per-week plan breakdown.
///
/// Mirrors the same MVVM shape as [BillingViewModel]: screens only ever
/// call methods here, never touch [BudgetRepository]/Hive directly.
class BudgetViewModel extends ChangeNotifier {
  BudgetViewModel({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository();

  final BudgetRepository _repository;

  double? budgetFor(DateTime month) =>
      _repository.getBudget(DateHelper.monthKey(month))?.amount;

  Future<void> setBudgetFor(DateTime month, double amount) async {
    await _repository.setBudget(DateHelper.monthKey(month), amount);
    notifyListeners();
  }

  /// The planned amount for a specific week. Falls back to an even split
  /// of the month's total budget across its weeks when the user hasn't
  /// customized that week's plan yet.
  double plannedFor(WeekOfMonth week, DateTime month) {
    final custom = _repository.getWeekPlan(week.idFor(month))?.plannedAmount;
    if (custom != null) return custom;

    final monthBudget = budgetFor(month);
    if (monthBudget == null) return 0;
    final weekCount = DateHelper.weeksInMonth(month).length;
    return weekCount == 0 ? 0 : monthBudget / weekCount;
  }

  Future<void> setPlanFor(WeekOfMonth week, DateTime month, double amount) async {
    await _repository.setWeekPlan(week.idFor(month), amount);
    notifyListeners();
  }
}
