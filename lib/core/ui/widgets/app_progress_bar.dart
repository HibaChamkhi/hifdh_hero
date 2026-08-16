import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';

/// Rounded progress bar used for surah/juz progress (e.g. "85% محفوظة").
///
/// Fills from the right in RTL — it reads [Directionality] via
/// [LinearProgressIndicator], so no manual mirroring is needed.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color? color;
  final Color? trackColor;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height.h,
        backgroundColor: trackColor ?? AppColors.borderStrong,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );
  }
}

/// Segmented progress used at the top of a challenge run — one bar per
/// question, filled as the user advances (screen 15).
class SegmentedProgress extends StatelessWidget {
  final int total;
  final int completed;
  final double height;

  const SegmentedProgress({
    super.key,
    required this.total,
    required this.completed,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    return Row(
      children: [
        for (int i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: height.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: i < completed ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
      ],
    );
  }
}
