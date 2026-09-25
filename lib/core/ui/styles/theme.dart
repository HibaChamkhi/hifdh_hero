import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimens.dart';
import 'text_styles.dart';

/// App-wide light & dark themes. RTL is enforced globally via the app locale
/// (see `main.dart` → supportedLocales / locale: ar).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.mintStrong,
        onSecondary: AppColors.primaryDark,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: _textTheme(AppColors.textPrimary, Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      splashColor: AppColors.mint.withValues(alpha: 0.4),
      highlightColor: AppColors.mint.withValues(alpha: 0.25),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.background,
        border: AppColors.border,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(AppColors.primary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryDarker,
        contentTextStyle: TextStyle(color: AppColors.onPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryMid,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMid,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.mintStrong,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.danger,
      ),
      textTheme: _textTheme(AppColors.darkTextPrimary, Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      inputDecorationTheme: _inputTheme(
        fill: AppColors.darkSurface,
        border: AppColors.darkBorder,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(AppColors.mintStrong),
    );
  }

  /// Starts from the Material defaults so every slot exists — dialogs, list
  /// tiles and snackbars read slots the app's own styles don't define — then
  /// applies the Arabic UI face across all of them and overrides the slots the
  /// design system has an opinion about.
  static TextTheme _textTheme(Color color, Brightness brightness) {
    final typography = Typography.material2021();
    final base = brightness == Brightness.dark
        ? typography.white
        : typography.black;
    return base
        .apply(
          fontFamily: AppTextStyles.uiFont,
          bodyColor: color,
          displayColor: color,
        )
        .copyWith(
          headlineLarge: AppTextStyles.pageTitle.copyWith(color: color),
          headlineMedium: AppTextStyles.h2.copyWith(color: color),
          titleLarge: AppTextStyles.h3.copyWith(color: color),
          bodyLarge: AppTextStyles.body.copyWith(color: color),
          bodyMedium: AppTextStyles.body.copyWith(color: color),
          labelLarge: AppTextStyles.button,
        );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
  }) {
    OutlineInputBorder side(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.md + 2,
      ),
      border: side(border),
      enabledBorder: side(border),
      focusedBorder: side(AppColors.primary, 1.4),
      errorBorder: side(AppColors.danger),
      focusedErrorBorder: side(AppColors.danger, 1.4),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color color) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: AppTextStyles.bodyStrong,
      ),
    );
  }
}
