import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/diamond_mark.dart';

/// A selectable memorization-level row (screen 02).
///
/// Selected → mint fill, deep-green border and label, filled diamond.
/// Unselected → cream fill, hairline border, hollow diamond.
class LevelOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const LevelOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
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
          height: AppDimens.rowHeight.h,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
          decoration: BoxDecoration(
            color: selected ? AppColors.mint : Colors.transparent,
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              DiamondMark(size: 20, filled: selected),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.h3.copyWith(
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
