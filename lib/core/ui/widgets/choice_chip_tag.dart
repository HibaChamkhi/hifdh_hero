import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// Pill chip used for surah tags / filters (e.g. "الفاتحة", "الناس").
///
/// Selected → solid mint with deep-green label and no border.
/// [dashed]  → the "+ المزيد" affordance: dashed hairline, no fill.
class ChoiceChipTag extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dashed;
  final VoidCallback? onTap;

  const ChoiceChipTag({
    super.key,
    required this.label,
    this.selected = false,
    this.dashed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      height: 44.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
      decoration: dashed
          ? null
          : BoxDecoration(
              color: selected ? AppColors.mint : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill.r),
            ),
      child: Text(
        label,
        style: AppTextStyles.bodyStrong.copyWith(
          color: selected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: dashed
          ? CustomPaint(
              painter: _DashedPillPainter(color: AppColors.borderStrong),
              child: chip,
            )
          : chip,
    );
  }
}

/// Draws the dashed pill outline behind the "+ المزيد" chip.
class _DashedPillPainter extends CustomPainter {
  final Color color;
  const _DashedPillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    final path = Path()..addRRect(rrect);

    const double dash = 6;
    const double gap = 5;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPillPainter oldDelegate) =>
      oldDelegate.color != color;
}
