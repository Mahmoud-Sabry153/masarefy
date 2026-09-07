import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neon_colors.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/budget_ring.dart';
import '../budget/budget_screen.dart';
import '../item_form/item_form_screen.dart';
import '../week/week_screen.dart';
import 'widgets/month_header.dart';
import 'widgets/week_card.dart';

/// The app's landing screen: the current month, its budget vs spending
/// ring, and the list of weeks that month is split into.
///
/// This is the top of the "Month -> Weeks -> Days" drill-down the app
/// spec asks for; tapping a week pushes [WeekScreen], which in turn
/// pushes a day.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _month = DateHelper.startOfMonth(DateTime.now());

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingViewModel>();
    final budget = context.watch<BudgetViewModel>();
    final weeks = DateHelper.weeksInMonth(_month);
    final spent = billing.totalForMonth(_month);
    final monthBudget = budget.budgetFor(_month);
    final fraction = (monthBudget == null || monthBudget == 0)
        ? 0.0
        : spent / monthBudget;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Masarefy',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: NeonColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Set monthly budget',
                            icon: const Icon(Icons.tune, color: NeonColors.secondary),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BudgetScreen(month: _month),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MonthHeader(
                        month: _month,
                        onPrevious: () => _changeMonth(-1),
                        onNext: () => _changeMonth(1),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: BudgetRing(
                          fraction: fraction,
                          centerLabel: CurrencyHelper.formatCompact(spent),
                          subLabel: monthBudget == null
                              ? 'no budget set'
                              : 'of ${CurrencyHelper.formatCompact(monthBudget)}',
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Weeks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final week = weeks[index];
                      return AnimatedListItem(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: WeekCard(
                            week: week,
                            spent: billing.totalForWeek(week),
                            planned: budget.plannedFor(week, _month),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WeekScreen(week: week, month: _month),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: weeks.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemFormScreen(initialDate: DateTime.now())),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }
}
