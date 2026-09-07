/// Names of the Hive boxes used for local, on-device persistence.
///
/// Centralized so a typo in a box name can't silently create a second,
/// disconnected box somewhere in the codebase.
class HiveBoxes {
  HiveBoxes._();

  static const String billingItems = 'billing_items_box';
  static const String monthlyBudgets = 'monthly_budgets_box';
  static const String weekPlans = 'week_plans_box';
}

/// Hive `typeId`s for registered adapters. Each model gets a permanent,
/// never-reused id — see docs/design_pattern.md for why this matters.
class HiveTypeIds {
  HiveTypeIds._();

  static const int billingItem = 0;
  static const int monthlyBudget = 1;
  static const int weekPlan = 2;
}
