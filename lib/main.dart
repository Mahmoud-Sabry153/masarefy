import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'models/billing_item.dart';
import 'models/monthly_budget.dart';
import 'models/week_plan.dart';

/// App entry point.
///
/// Everything here is set-up-once, synchronous-feeling work: initialize
/// Hive's on-device storage, register each model's adapter, and open the
/// three boxes the app uses — all *before* `runApp`, so every screen can
/// assume storage is already ready and never has to handle a "loading
/// database" state.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BillingItemAdapter());
  Hive.registerAdapter(MonthlyBudgetAdapter());
  Hive.registerAdapter(WeekPlanAdapter());

  await Future.wait([
    Hive.openBox<BillingItem>(HiveBoxes.billingItems),
    Hive.openBox<MonthlyBudget>(HiveBoxes.monthlyBudgets),
    Hive.openBox<WeekPlan>(HiveBoxes.weekPlans),
  ]);

  runApp(const MasarefyApp());
}
