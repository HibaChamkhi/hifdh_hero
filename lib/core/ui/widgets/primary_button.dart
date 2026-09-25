import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// Full-width rounded primary CTA used across the app
/// (e.g. "ابدأ رحلتي", "تسجيل الدخول", "متابعة").
///
/// Measured from the exports: 60pt tall, 16pt corner radius, flat deep green.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final Color? color;
  final Color? foreground;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.color,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = enabled && !loading && onPressed != null;
    final Color bg = color ?? AppColors.primary;
    final Color fg = foreground ?? AppColors.onPrimary;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight.h,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withValues(alpha: 0.35),
          disabledForegroundColor: fg.withValues(alpha: 0.7),
          foregroundColor: fg,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
          ),
        ),
        child: loading
            ? SizedBox(
                height: 22.h,
                width: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Text(label, style: AppTextStyles.button.copyWith(color: fg)),
      ),
    );
  }
}

/// The quiet secondary action under a CTA ("تخطي الآن", "العودة لتسجيل الدخول").
class SubtleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const SubtleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 44.h),
        foregroundColor: color ?? AppColors.textMuted,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyStrong.copyWith(
          color: color ?? AppColors.textMuted,
        ),
      ),
    );
  }
}
