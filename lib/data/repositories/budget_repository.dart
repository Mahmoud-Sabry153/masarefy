import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../models/monthly_budget.dart';
import '../../models/week_plan.dart';

/// Data-access layer for [MonthlyBudget]s and [WeekPlan]s.
///
/// Both models are small and closely related (a week plan only makes
/// sense in the context of a month's budget), so they share one
/// repository — unlike [BillingRepository] which is dedicated to the
/// much higher-traffic billing items box.
class BudgetRepository {
  Box<MonthlyBudget> get _budgetBox =>
      Hive.box<MonthlyBudget>(HiveBoxes.monthlyBudgets);

  Box<WeekPlan> get _planBox => Hive.box<WeekPlan>(HiveBoxes.weekPlans);

  MonthlyBudget? getBudget(String monthKey) => _budgetBox.get(monthKey);

  Future<void> setBudget(String monthKey, double amount) {
    final existing = _budgetBox.get(monthKey);
    if (existing != null) {
      existing.amount = amount;
      return existing.save();
    }
    return _budgetBox.put(
      monthKey,
      MonthlyBudget(monthKey: monthKey, amount: amount),
    );
  }

  WeekPlan? getWeekPlan(String weekId) => _planBox.get(weekId);

  Future<void> setWeekPlan(String weekId, double amount) {
    final existing = _planBox.get(weekId);
    if (existing != null) {
      existing.plannedAmount = amount;
      return existing.save();
    }
    return _planBox.put(weekId, WeekPlan(weekId: weekId, plannedAmount: amount));
  }
}
