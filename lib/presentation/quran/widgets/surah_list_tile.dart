import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../domain/quran/models/surah.dart';

/// Row for the "اختر السورة" list (screen 09).
///
/// RTL layout, right to left: number badge · name + meta · trailing stat.
/// The highlighted row picks up the mint fill and green border from the mock.
class SurahListTile extends StatelessWidget {
  final Surah surah;
  final bool highlighted;
  final VoidCallback? onTap;

  /// Optional 0..1 memorisation progress. When null the row falls back to the
  /// juz label, which is what the local Quran data can supply today.
  final double? progress;

  const SurahListTile({
    super.key,
    required this.surah,
    this.highlighted = false,
    this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusMd.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.sm.w,
            vertical: AppDimens.sm.h,
          ),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.mint : AppColors.surface,
            borderRadius: radius,
            border: highlighted
                ? Border.all(color: AppColors.primary, width: 1.4)
                : null,
          ),
          child: Row(
            children: [
              _NumberBadge(number: surah.number, highlighted: highlighted),
              SizedBox(width: AppDimens.sm.w),
              // Name + meta (RTL: reads immediately left of the badge).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      surah.name,
                      style: AppTextStyles.h3.copyWith(
                        color: highlighted
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${surah.ayahCount} آية · ${surah.revelationType.arabicLabel}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.xs.w),
              // Trailing stat on the far left.
              Text(
                progress != null
                    ? '${(progress! * 100).round()}%'
                    : 'جزء ${surah.startJuz}',
                style: AppTextStyles.bodyStrong.copyWith(
                  fontFamily: progress != null
                      ? AppTextStyles.latinFont
                      : AppTextStyles.uiFont,
                  color: highlighted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final bool highlighted;
  const _NumberBadge({required this.number, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm.r),
      ),
      child: Text(
        '$number',
        style: AppTextStyles.bodyStrong.copyWith(
          fontFamily: AppTextStyles.latinFont,
          fontSize: 17.sp,
          color: highlighted ? AppColors.onPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
