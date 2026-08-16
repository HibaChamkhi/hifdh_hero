import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// The brand mark: a mint rounded square holding the Arabic wordmark "حفظ"
/// in deep green (screens 00/01/02/04/05/06).
///
/// The exports draw a hand-lettered glyph; until the SVG/PNG asset is added to
/// `assets/images/` this renders the same word as text, which keeps the mark
/// crisp at every size. Pass [asset] to swap in the artwork.
class HifzLogo extends StatelessWidget {
  final double size;
  final String? asset;

  const HifzLogo({super.key, this.size = AppDimens.logoBadge, this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular((size * 0.32).r),
      ),
      alignment: Alignment.center,
      child: asset != null
          ? Padding(
              padding: EdgeInsets.all((size * 0.22).w),
              child: Image.asset(asset!, fit: BoxFit.contain),
            )
          : Text(
              'حفظ',
              textAlign: TextAlign.center,
              style: AppTextStyles.h1.copyWith(
                fontSize: (size * 0.42).sp,
                height: 1.0,
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
