import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// The paired stat tiles that sit under a section: a large value over a small
/// grey caption. Contents read from the right, like the rest of the app.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? background;
  final Color? valueColor;
  final bool latinValue;
  final EdgeInsetsGeometry? padding;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.background,
    this.valueColor,
    this.latinValue = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppDimens.md.w,
            vertical: AppDimens.lg.h,
          ),
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.statNumber.copyWith(
              fontFamily:
                  latinValue ? AppTextStyles.latinFont : AppTextStyles.uiFont,
              fontSize: 24.sp,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimens.xxs.h),
          Text(
            label,
            textAlign: TextAlign.right,
            style: AppTextStyles.statLabel,
          ),
        ],
      ),
    );
  }
}

/// Compact inline stat (value over label, no card) — used on the result screen.
class InlineStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const InlineStat({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.right,
          style: AppTextStyles.statNumber.copyWith(
            fontSize: 22.sp,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimens.xxs.h),
        Text(
          label,
          textAlign: TextAlign.right,
          style: AppTextStyles.statLabel,
        ),
      ],
    );
  }
}
