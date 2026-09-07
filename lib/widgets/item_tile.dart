import 'package:flutter/material.dart';
import '../core/theme/neon_colors.dart';
import '../core/utils/currency_helper.dart';
import '../models/billing_item.dart';
import 'neon_card.dart';

/// A single billing item row, used in the Day screen (and anywhere else
/// a flat list of items is shown). Swipe-to-delete via [Dismissible] so
/// deleting an item is a quick gesture rather than a menu hunt.
class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final BillingItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: NeonColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeonColors.danger.withOpacity(0.6)),
        ),
        child: const Icon(Icons.delete_outline, color: NeonColors.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: NeonCard(
          onTap: onTap,
          glowColor: NeonColors.primary,
          intensity: 0.3,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 16),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                CurrencyHelper.format(item.amount),
                style: const TextStyle(
                  color: NeonColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
