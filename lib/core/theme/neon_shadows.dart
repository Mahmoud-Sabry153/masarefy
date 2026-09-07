import 'package:flutter/material.dart';
import 'neon_colors.dart';

/// Reusable "glow" box-shadow presets.
///
/// A neon glow is really just 2-3 stacked, blurred, semi-transparent
/// shadows of the same color. Centralizing the presets here means every
/// glowing card/button in the app looks consistent, and the glow
/// intensity can be tuned globally (e.g. for accessibility/performance)
/// in one spot.
class NeonShadows {
  NeonShadows._();

  static List<BoxShadow> glow(Color color, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.55 * intensity),
        blurRadius: 8 * intensity,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: color.withOpacity(0.35 * intensity),
        blurRadius: 24 * intensity,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withOpacity(0.18 * intensity),
        blurRadius: 48 * intensity,
        spreadRadius: 2,
      ),
    ];
  }

  static List<BoxShadow> get card => glow(NeonColors.primary, intensity: 0.5);
  static List<BoxShadow> get cardHover => glow(NeonColors.primary, intensity: 1.0);
  static List<BoxShadow> get danger => glow(NeonColors.danger, intensity: 0.8);
  static List<BoxShadow> get safe => glow(NeonColors.safe, intensity: 0.8);
}
