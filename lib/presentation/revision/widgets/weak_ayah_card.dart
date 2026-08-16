import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/utils/day.dart';
import '../../../domain/revision/models/revision_item.dart';
import 'strength_stars.dart';

/// Weak-ayah card with strength, last-reviewed, and a "راجع الآن" action
/// (screen 31).
///
/// The card is tinted by weakness — rose for the weakest ayahs, peach next —
/// and the action sits inside it as a white full-width button.
class WeakAyahCard extends StatelessWidget {
  final RevisionItem item;
  final int today;
  final VoidCallback onReview;

  const WeakAyahCard({
    super.key,
    required this.item,
    required this.today,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final s = item.state;
    final bool weakest = s.box <= 1;
    final Color bg = weakest
        ? AppColors.rose
        : (s.box == 2 ? AppColors.peach : AppColors.surface);
    final Color accent = weakest
        ? AppColors.roseText
        : (s.box == 2 ? AppColors.terracotta : AppColors.primary);

    final last =
        s.lastReviewedDay < 0 ? '—' : Day.agoLabel(s.lastReviewedDay, today);

    return Container(
      padding: EdgeInsets.all(AppDimens.lg.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: StrengthStars(stars: s.stars, color: accent),
          ),
          SizedBox(height: AppDimens.sm.h),
          Text(
            '${item.surahName} ${item.ayahNumber}',
            textAlign: TextAlign.right,
            style: AppTextStyles.h3.copyWith(color: accent),
          ),
          SizedBox(height: AppDimens.xs.h),
          Text(
            'آخر مراجعة: $last',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: accent.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: AppDimens.md.h),
          SizedBox(
            height: 52.h,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: accent,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
                ),
              ),
              child: Text(
                'راجع الآن',
                style: AppTextStyles.bodyStrong.copyWith(color: accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
