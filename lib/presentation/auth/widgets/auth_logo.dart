import 'package:flutter/material.dart';
import '../../../core/ui/widgets/hifz_logo.dart';

/// The rounded mint badge with the "حفظ" wordmark, used on the auth screens.
///
/// Kept as a thin alias so the auth pages keep a feature-local name while the
/// mark itself lives in `core/ui/widgets/hifz_logo.dart`.
///
/// Always horizontally centred: the centring lives here rather than at each
/// call site so every auth screen places the mark identically. Expects a
/// parent that gives it the full width (e.g. a stretched [Column]).
class AuthLogo extends StatelessWidget {
  final double size;
  const AuthLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) => Center(child: HifzLogo(size: size));
}
