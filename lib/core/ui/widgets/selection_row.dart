import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// The selectable pill row that appears wherever the user picks one thing from
/// a list: memorised surahs (03), MCQ answers (16/20/23), settings choices.
///
/// Selected  → mint fill, deep-green label, filled circle at the start (right).
/// Unselected→ transparent fill, hairline border, hollow circle.
class SelectionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Use the stronger mint (#B6E1C3) for a solid, borderless row — matches the
  /// "السور التي حفظتها" list on screen 03.
  final bool solid;

  const SelectionRow({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = selected
        ? (solid ? AppColors.mintStrong : AppColors.mint)
        : Colors.transparent;
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
            color: fill,
            borderRadius: radius,
            border: selected && solid
                ? null
                : Border.all(
                    color:
                        selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.4 : 1,
                  ),
          ),
          child: Row(
            children: [
              _Dot(selected: selected),
              SizedBox(width: AppDimens.sm.w),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool selected;
  const _Dot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: AppColors.borderStrong, width: 1.4),
      ),
    );
  }
}
