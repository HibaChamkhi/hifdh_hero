import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography for Hifz Hero.
///
/// - [uiFont]    : Arabic UI font. Left null to fall back to the platform
///                 Arabic system font. Bundle Tajawal/Cairo and set this to
///                 'Tajawal' for a pixel-match with the mockups.
/// - [quranFont] : dedicated Uthmani/Quran font (e.g. 'AmiriQuran' or
///                 'UthmanicHafs') for rendering ayah text.
/// - Poppins     : Latin numerals/labels (bundled, same as the starter).
class AppTextStyles {
  AppTextStyles._();

  static const String? uiFont = null; // set to 'Tajawal' once bundled
  static const String latinFont = 'Poppins';
  static const String quranFont = 'AmiriQuran'; // bundle before using

  // ---- Page header (big right-aligned title + grey subtitle) ----
  static const TextStyle pageTitle = TextStyle(
    fontFamily: uiFont,
    fontSize: 26,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---- Headings ----
  static const TextStyle h1 = TextStyle(
    fontFamily: uiFont,
    fontSize: 26,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: uiFont,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: uiFont,
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ---- Body ----
  static const TextStyle body = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---- Buttons / labels ----
  static const TextStyle button = TextStyle(
    fontFamily: uiFont,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );

  /// Small right-aligned section label above a group ("مستوى الحفظ").
  static const TextStyle label = TextStyle(
    fontFamily: uiFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Bottom-navigation label.
  static const TextStyle navLabel = TextStyle(
    fontFamily: uiFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  /// Breadcrumb above a detail screen ("‹ اختر السورة").
  static const TextStyle breadcrumb = TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---- Numerals / stats (Latin/Poppins) ----
  static const TextStyle statNumber = TextStyle(
    fontFamily: latinFont,
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: uiFont,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ---- Quran ayah text ----
  static const TextStyle ayah = TextStyle(
    fontFamily: quranFont,
    fontSize: 26,
    height: 1.9,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryDark,
  );
}
