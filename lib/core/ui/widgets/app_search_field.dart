import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';
import '../styles/dimens.dart';
import '../styles/text_styles.dart';

/// The filled, borderless search field used on the surah lists
/// ("ابحثي عن سورة..." — screens 03/09/12).
class AppSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.inputHeight.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimens.md.w,
            vertical: AppDimens.md.h,
          ),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
        ),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg.r),
        borderSide: BorderSide.none,
      );
}
