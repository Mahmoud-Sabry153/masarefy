import 'package:flutter/material.dart';
import '../core/theme/neon_colors.dart';
import '../core/theme/neon_shadows.dart';

/// A rounded, glowing surface used all over the app for cards, tiles and
/// panels — the single visual building block that gives Masarefy its
/// "neon" identity, so the glow effect is defined once and reused rather
/// than re-implemented per screen.
///
/// Animates its own glow intensity in on first build via an implicit
/// [TweenAnimationBuilder], which is what gives cards their soft
/// "power-on" entrance instead of popping in at full brightness.
class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.glowColor = NeonColors.primary,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 20,
    this.intensity = 0.55,
  });

  final Widget child;
  final Color glowColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: intensity),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: NeonColors.surface,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: glowColor.withOpacity(0.4 + value * 0.3),
                ),
                boxShadow: NeonShadows.glow(glowColor, intensity: value),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
