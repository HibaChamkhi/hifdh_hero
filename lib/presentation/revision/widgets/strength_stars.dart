import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';

/// 0..5 star rating for an ayah's retention strength.
///
/// RTL: filled stars fill from the right, matching screen 31.
class StrengthStars extends StatelessWidget {
  final int stars; // 0..5
  final Color? color;
  final double size;

  const StrengthStars({
    super.key,
    required this.stars,
    this.color,
    this.size = 17,
  });

  @override
  Widget build(BuildContext context) {
    final filled = stars.clamp(0, 5);
    final Color tint = color ?? AppColors.terracotta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Icon(
              i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size.sp,
              color: i < filled ? tint : tint.withValues(alpha: 0.45),
            ),
          ),
      ],
    );
  }
}
