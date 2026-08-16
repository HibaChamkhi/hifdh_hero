/// Spacing, radius and sizing tokens. Use with flutter_screenutil (.w/.h/.r)
/// at call sites, e.g. `SizedBox(height: AppDimens.md.h)`.
///
/// Values are the design exports' pixel measurements halved (the mocks are
/// rendered at 750x1624 = @2x of a 375x812 logical canvas).
class AppDimens {
  AppDimens._();

  // Spacing scale (4-pt based)
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Radii — measured: rows 30px, cards 32px, buttons 33px, prompt cards 35px.
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 18;
  static const double radiusXl = 26;
  static const double radiusPill = 999;

  // Screen padding — content spans x=48..701 (@2x) => 24pt gutters.
  static const double screenH = 24;
  static const double screenV = 16;

  // Common sizes
  static const double buttonHeight = 60;
  static const double inputHeight = 58;
  static const double rowHeight = 56;
  static const double bottomNavHeight = 76;
  static const double logoBadge = 60;
  static const double iconTile = 56;
}
