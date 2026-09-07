import 'package:flutter/material.dart';
import '../../../core/theme/neon_colors.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/date_helper.dart';
import '../../../widgets/neon_card.dart';

/// One row on the Home screen representing a whole week of the current
/// month: "Week 1 · Sep 1 - Sep 7", spent vs planned, tap to drill into
/// [WeekScreen].
class WeekCard extends StatelessWidget {
  const WeekCard({
    super.key,
    required this.week,
    required this.spent,
    required this.planned,
    required this.onTap,
  });

  final WeekOfMonth week;
  final double spent;
  final double planned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final over = planned > 0 && spent > planned;
    final range = week.days.length == 1
        ? _shortDate(week.firstDay)
        : '${_shortDate(week.firstDay)} - ${_shortDate(week.lastDay)}';

    return NeonCard(
      onTap: onTap,
      glowColor: over ? NeonColors.danger : NeonColors.secondary,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NeonColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (over ? NeonColors.danger : NeonColors.secondary)
                    .withOpacity(0.6),
              ),
            ),
            child: Text(
              'W${week.index}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: over ? NeonColors.danger : NeonColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(range, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  planned > 0
                      ? '${CurrencyHelper.format(spent)} of ${CurrencyHelper.format(planned)} planned'
                      : '${CurrencyHelper.format(spent)} spent',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: NeonColors.textSecondary),
        ],
      ),
    );
  }

  String _shortDate(DateTime d) =>
      '${DateHelper.monthNames[d.month - 1].substring(0, 3)} ${d.day}';
}
