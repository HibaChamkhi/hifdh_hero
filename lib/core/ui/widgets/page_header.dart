import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// The page header used at the top of every screen: a large bold title with an
/// optional grey subtitle beneath it.
///
/// Always reads from the right — the app is Arabic/RTL throughout, so text is
/// aligned to the start of the line and never centred.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.pageTitle, textAlign: TextAlign.right),
        if (subtitle != null) ...[
          SizedBox(height: AppDimens.xxs.h),
          Text(
            subtitle!,
            style: AppTextStyles.pageSubtitle,
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }
}

/// The small muted breadcrumb shown above a pushed detail screen
/// ("‹ اختر السورة" on 14, "سورة الملك · تحديات السورة" on 15).
class Breadcrumb extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const Breadcrumb({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: AppTextStyles.breadcrumb,
      textAlign: TextAlign.right,
    );
    return Align(
      alignment: Alignment.centerRight,
      child: onTap == null
          ? text
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimens.xs.h),
                child: text,
              ),
            ),
    );
  }
}
