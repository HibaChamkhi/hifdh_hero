import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';

/// The mint prompt card that shows the ayah / word for a question
/// (screens 15/16/20/23): flat mint fill, 18pt corners, green ayah text
/// reading from the right.
class QuestionPromptCard extends StatelessWidget {
  final String text;
  final String? subtitle;
  final double? minHeight;

  const QuestionPromptCard({
    super.key,
    required this.text,
    this.subtitle,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: (minHeight ?? 130).h),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg.w,
        vertical: AppDimens.lg.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: AppTextStyles.ayah.copyWith(fontSize: 24.sp),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppDimens.sm.h),
            Text(
              subtitle!,
              textAlign: TextAlign.right,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryDark),
            ),
          ],
        ],
      ),
    );
  }
}

/// The dashed "your answer goes here" slot beneath the prompt on the
/// free-entry challenges (screen 15).
class AnswerSlot extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;

  const AnswerSlot({
    super.key,
    this.value,
    this.placeholder = '— — — — —',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool filled = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBoxPainter(
          color: AppColors.borderStrong,
          radius: AppDimens.radiusLg,
        ),
        child: Container(
          width: double.infinity,
          height: 96.h,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
          child: Text(
            filled ? value! : placeholder,
            textAlign: TextAlign.right,
            style: filled
                ? AppTextStyles.ayah.copyWith(fontSize: 22.sp)
                : AppTextStyles.h3.copyWith(color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBoxPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    const double dash = 7;
    const double gap = 6;
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
  bool shouldRepaint(covariant _DashedBoxPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
