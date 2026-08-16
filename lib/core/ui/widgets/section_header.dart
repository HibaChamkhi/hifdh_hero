import 'package:flutter/material.dart';
import '../styles/text_styles.dart';

/// Section label above a list/section ("مستوى الحفظ", "السور التي حفظتها",
/// "اختاري تحديًا").
///
/// RTL: the title is the first child so it sits against the right edge, with
/// any [trailing] action pushed to the left.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final TextStyle? style;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.style,
  });

  /// Larger variant used where the section reads as a heading rather than a
  /// field label (screen 14 — "اختاري تحديًا").
  const SectionHeader.strong({
    super.key,
    required this.title,
    this.trailing,
  }) : style = AppTextStyles.h3;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          textAlign: TextAlign.right,
          style: style ?? AppTextStyles.label,
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
