import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';

/// The rounded diamond used as a selection indicator and as the celebratory
/// mark on the result screen (screens 02/07/24).
class DiamondMark extends StatelessWidget {
  final double size;
  final bool filled;
  final Color? color;
  final Color? borderColor;

  const DiamondMark({
    super.key,
    this.size = 22,
    this.filled = true,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? AppColors.primary;
    return Transform.rotate(
      angle: 0.785398, // 45°
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: filled ? fill : Colors.transparent,
          borderRadius: BorderRadius.circular((size * 0.27).r),
          border: filled
              ? null
              : Border.all(
                  color: borderColor ?? AppColors.borderStrong,
                  width: 1.6,
                ),
        ),
      ),
    );
  }
}

/// The three-diamond celebration cluster on the challenge result screen (24).
class DiamondCluster extends StatelessWidget {
  final int count;
  final double size;
  final Color? color;

  const DiamondCluster({
    super.key,
    this.count = 3,
    this.size = 34,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: (size * 0.12).w),
          DiamondMark(size: size, color: color),
        ],
      ],
    );
  }
}
