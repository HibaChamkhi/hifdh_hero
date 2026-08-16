import 'package:flutter/material.dart';

/// Hifz Hero color system.
///
/// Values sampled pixel-exactly from the refreshed design exports
/// (`exports/00..42-*.png`, Aug 2026 revision). Grouped as semantic roles so
/// screens never hard-code hex values.
class AppColors {
  AppColors._();

  // ---- Brand / primary (the Hifz green) ----
  static const Color primary = Color(0xFF266741); // buttons, active nav, marks
  static const Color primaryDark = Color(0xFF1E5335); // text on mint
  static const Color primaryDarker = Color(0xFF17402A); // ayah text
  static const Color primaryMid = Color(0xFF5D9D74); // heatmap fill, soft bars

  // ---- Secondary surfaces (mint) ----
  static const Color mint = Color(0xFFD6EFDE); // prompt cards, selected chips
  static const Color mintStrong = Color(0xFFB6E1C3); // selected list rows
  static const Color mintSoft = Color(0xFFE0EBE4); // icon tiles, logo badge

  // ---- Accent (terracotta / warm) — streaks, XP ----
  static const Color terracotta = Color(0xFFC67854);
  static const Color peach = Color(0xFFFAE2D8); // warm surface card
  static const Color peachStrong = Color(0xFFF7C9B4);
  static const Color peachSoft = Color(0xFFFDF0E9);

  // ---- Rose (due / overdue revision) ----
  static const Color rose = Color(0xFFFACECD);
  static const Color roseText = Color(0xFFB54A4B);

  // ---- Sand / gold (audio & voice) ----
  static const Color gold = Color(0xFFB89A5A);
  static const Color goldSurface = Color(0xFFF3E7CE);

  // ---- Backgrounds & surfaces ----
  static const Color background = Color(0xFFFAF6EF); // cream canvas
  static const Color surface = Color(0xFFF4F1EC); // card / input / row fill
  static const Color surfaceElevated = Color(0xFFFCFCFA); // card on tinted bg
  static const Color surfaceAlt = Color(0xFFF1EFE9);

  // ---- Text ----
  static const Color textPrimary = Color(0xFF161D16);
  static const Color textSecondary = Color(0xFF7C7A74);
  static const Color textTertiary = Color(0xFFA9A79F);
  static const Color textMuted = Color(0xFF576157);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---- Borders / dividers ----
  static const Color border = Color(0xFFE7E4DF);
  static const Color borderStrong = Color(0xFFD8D5CE);

  // ---- Feedback ----
  static const Color success = Color(0xFF266741);
  static const Color danger = Color(0xFFB54A4B);
  static const Color dangerSurface = Color(0xFFFACECD);
  static const Color warningSurface = Color(0xFFFAE2D8);

  // ---- Dark theme ----
  static const Color darkBackground = Color(0xFF10170F);
  static const Color darkSurface = Color(0xFF19211A);
  static const Color darkBorder = Color(0xFF2A342A);
  static const Color darkTextPrimary = Color(0xFFF2F4F1);
  static const Color darkTextSecondary = Color(0xFF9DA69B);
}
