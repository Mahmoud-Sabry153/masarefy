import 'package:flutter/material.dart';
import '../../../core/theme/neon_colors.dart';
import '../../../core/utils/date_helper.dart';

/// The month switcher at the top of the Home screen: "< September 2026 >".
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrevious),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            DateHelper.monthLabel(month),
            key: ValueKey(DateHelper.monthKey(month)),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        _NavButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NeonColors.surfaceElevated,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: NeonColors.primary),
        ),
      ),
    );
  }
}
