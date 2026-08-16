import 'package:flutter/material.dart';
import '../../../core/ui/widgets/hifz_logo.dart';

/// The rounded mint badge with the "حفظ" wordmark, used on the auth screens.
///
/// Kept as a thin alias so the auth pages keep a feature-local name while the
/// mark itself lives in `core/ui/widgets/hifz_logo.dart`.
class AuthLogo extends StatelessWidget {
  final double size;
  const AuthLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) => HifzLogo(size: size);
}
