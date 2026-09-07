import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neon_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../widgets/neon_card.dart';

/// Lets the user set (or change) the total budget for one month. Per-week
/// planning is done inline on [WeekScreen] instead, since it only makes
/// sense once you're looking at that specific week.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final existing = context.read<BudgetViewModel>().budgetFor(widget.month);
    _controller = TextEditingController(
      text: existing != null ? existing.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    await context.read<BudgetViewModel>().setBudgetFor(widget.month, value);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final weekCount = DateHelper.weeksInMonth(widget.month).length;
    return Scaffold(
      appBar: AppBar(title: Text('Budget · ${DateHelper.monthLabel(widget.month)}')),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              NeonCard(
                glowColor: NeonColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set how much you plan to spend this month.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monthly budget'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will default-split evenly across the $weekCount weeks '
                      'of this month. You can fine-tune each week\'s plan from '
                      'that week\'s screen.',
                      style: const TextStyle(color: NeonColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save budget')),
            ],
          ),
        ),
      ),
    );
  }
}
