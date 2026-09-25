import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../domain/challenges/models/challenge_type.dart';

/// A challenge option card on the hub (screen 14): a tinted icon tile above a
/// bold label and a grey question count, all aligned to the right.
class ChallengeTypeCard extends StatelessWidget {
  final ChallengeType type;
  final VoidCallback onTap;

  const ChallengeTypeCard({super.key, required this.type, required this.onTap});

  /// (tile background, glyph colour) per challenge, matching the exports.
  (Color, Color) get _tint {
    switch (type) {
      case ChallengeType.completeAyah:
        return (AppColors.mint, AppColors.primary);
      case ChallengeType.missingWord:
        return (AppColors.peach, AppColors.terracotta);
      case ChallengeType.findSurah:
        return (AppColors.mintSoft, AppColors.primaryDark);
      case ChallengeType.guessJuz:
        return (AppColors.goldSurface, AppColors.gold);
    }
  }

  IconData get _glyph {
    switch (type) {
      case ChallengeType.completeAyah:
        return Icons.notes_rounded;
      case ChallengeType.missingWord:
        return Icons.crop_free_rounded;
      case ChallengeType.findSurah:
        return Icons.search_rounded;
      case ChallengeType.guessJuz:
        return Icons.layers_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (tileColor, glyphColor) = _tint;
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusMd.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(AppDimens.md.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppDimens.iconTile.w,
                height: AppDimens.iconTile.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm.r),
                ),
                child: Icon(_glyph, size: 26.sp, color: glyphColor),
              ),
              SizedBox(height: AppDimens.sm.h),
              Text(
                type.arabicLabel,
                style: AppTextStyles.h3,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                '${type.defaultCount} أسئلة',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
