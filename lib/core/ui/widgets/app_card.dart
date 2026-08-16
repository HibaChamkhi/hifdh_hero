import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';

/// Rounded surface container used for stat tiles, list items, panels.
/// Flat by design — the exports use tint, not shadow, to separate surfaces.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? radius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.onTap,
    this.radius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius fallback = BorderRadius.circular(AppDimens.radiusMd.r);
    final BorderRadiusGeometry r = radius ?? fallback;
    final Widget content = Container(
      padding: padding ?? EdgeInsets.all(AppDimens.md.w),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: r,
        border: border,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r is BorderRadius ? r : fallback,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
