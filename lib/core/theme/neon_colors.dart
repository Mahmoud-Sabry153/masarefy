import 'package:flutter/material.dart';

/// Central palette for Masarefy's dark, neon-glow UI.
///
/// Kept in one place (rather than scattered literal colors through the
/// widget tree) so the whole app's mood can be re-tuned from a single file.
class NeonColors {
  NeonColors._();

  // Backgrounds — near-black with a faint blue tint so glows have
  // something dark to stand out against.
  static const Color background = Color(0xFF07080D);
  static const Color surface = Color(0xFF11131A);
  static const Color surfaceElevated = Color(0xFF171A24);

  // Neon accents.
  static const Color cyan = Color(0xFF00F0FF);
  static const Color purple = Color(0xFFB026FF);
  static const Color pink = Color(0xFFFF2E93);
  static const Color green = Color(0xFF39FF6A);
  static const Color amber = Color(0xFFFFC93C);

  // Semantic aliases so screens don't have to know *which* neon color
  // means "danger" or "safe" — only this file does.
  static const Color danger = pink;
  static const Color safe = green;
  static const Color warning = amber;
  static const Color primary = cyan;
  static const Color secondary = purple;

  static const Color textPrimary = Color(0xFFF3F6FF);
  static const Color textSecondary = Color(0xFF8C93A8);
  static const Color divider = Color(0xFF232838);

  /// A subtle gradient used behind headers/cards for depth without
  /// competing with the neon glow effects drawn on top.
  static const LinearGradient backdropGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0D14), Color(0xFF141726), Color(0xFF0B0D14)],
  );
}
