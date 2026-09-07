import 'package:flutter/material.dart';
import '../core/theme/neon_colors.dart';

/// A small, friendly placeholder shown wherever a list has no items yet
/// (a day with no expenses, a month with no items at all). Fades in so
/// it never just "pops" into an otherwise-empty screen.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: NeonColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: NeonColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
