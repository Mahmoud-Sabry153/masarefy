import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neon_colors.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/item_tile.dart';
import '../item_form/item_form_screen.dart';

/// The last level of the drill-down: every billing item logged on one
/// specific calendar [day], with add / edit / delete (swipe) actions.
class DayScreen extends StatelessWidget {
  const DayScreen({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingViewModel>();
    final items = billing.itemsForDay(day)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final total = billing.totalForDay(day);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${DateHelper.weekdayShort[day.weekday - 1]}, '
          '${DateHelper.monthNames[day.month - 1]} ${day.day}',
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total spent', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      CurrencyHelper.format(total),
                      style: const TextStyle(
                        color: NeonColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'No expenses logged for this day yet.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return AnimatedListItem(
                            index: index,
                            child: ItemTile(
                              item: item,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemFormScreen(
                                    initialDate: day,
                                    existingItem: item,
                                  ),
                                ),
                              ),
                              onDelete: () =>
                                  context.read<BillingViewModel>().deleteItem(item.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ItemFormScreen(initialDate: day)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
