import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';
import 'diamond_mark.dart';

/// The calm placeholder used for empty lists and not-yet-built tabs
/// (screen 42 — "حالات فارغة"): a soft tinted tile, a title, a grey line of
/// explanation and an optional action — all reading from the right.
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? tint;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: AppDimens.iconTile.w,
            height: AppDimens.iconTile.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint ?? AppColors.mint,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
            ),
            child: const DiamondMark(size: 20),
          ),
          SizedBox(height: AppDimens.md.h),
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.h3,
          ),
          if (message != null) ...[
            SizedBox(height: AppDimens.xxs.h),
            Text(
              message!,
              textAlign: TextAlign.right,
              style: AppTextStyles.caption,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppDimens.sm.h),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppDimens.xs.h),
              ),
              child: Text(
                actionLabel!,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
