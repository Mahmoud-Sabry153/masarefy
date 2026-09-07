import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neon_colors.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/neon_card.dart';
import '../day/day_screen.dart';

/// Shows every day of a single [WeekOfMonth], each with its own spend
/// total, and lets the user edit that week's plan amount. Tapping a day
/// drills down further into [DayScreen] — the last level of the
/// Month -> Week -> Day hierarchy.
class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key, required this.week, required this.month});

  final WeekOfMonth week;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingViewModel>();
    final budget = context.watch<BudgetViewModel>();
    final planned = budget.plannedFor(week, month);
    final spent = billing.totalForWeek(week);

    return Scaffold(
      appBar: AppBar(title: Text('Week ${week.index} · ${DateHelper.monthLabel(month)}')),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              NeonCard(
                glowColor: spent > planned && planned > 0
                    ? NeonColors.danger
                    : NeonColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Stat(label: 'Spent', value: CurrencyHelper.format(spent)),
                    _Stat(label: 'Planned', value: CurrencyHelper.format(planned)),
                    _EditPlanButton(week: week, month: month, initial: planned),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Days', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...List.generate(week.days.length, (index) {
                final day = week.days[index];
                final dayTotal = billing.totalForDay(day);
                return AnimatedListItem(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeonCard(
                      glowColor: NeonColors.secondary,
                      intensity: 0.35,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DayScreen(day: day)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: NeonColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              DateHelper.weekdayShort[day.weekday - 1],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                            ),
                          ),
                          Text(
                            CurrencyHelper.format(dayTotal),
                            style: const TextStyle(
                              color: NeonColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: NeonColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EditPlanButton extends StatelessWidget {
  const _EditPlanButton({
    required this.week,
    required this.month,
    required this.initial,
  });

  final WeekOfMonth week;
  final DateTime month;
  final double initial;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Edit week plan',
      icon: const Icon(Icons.edit_note, color: NeonColors.secondary),
      onPressed: () async {
        final controller = TextEditingController(
          text: initial > 0 ? initial.toStringAsFixed(0) : '',
        );
        final result = await showDialog<double>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: NeonColors.surfaceElevated,
            title: const Text('Plan for this week'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Planned amount'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text.trim());
                  Navigator.pop(context, value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
        if (result != null && context.mounted) {
          await context.read<BudgetViewModel>().setPlanFor(week, month, result);
        }
      },
    );
  }
}
