import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/hifz_logo.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/onboarding/repositories/onboarding_repository.dart';

/// Screen 01 — splash. Decides the first route based on onboarding state.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final onboarding = getIt<OnboardingRepository>();
    final auth = getIt<AuthRepository>();
    final String next;
    if (!onboarding.isOnboardingComplete()) {
      next = AppRoutes.onboarding;
    } else if (!auth.isLoggedIn) {
      next = AppRoutes.login;
    } else {
      next = AppRoutes.home;
    }
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
          // Scaffold hands its body *loose* width constraints, so the column
          // would shrink-wrap to its widest child and hug one edge; claiming
          // the full width is what gives `center` below something to centre in.
          child: SizedBox(
            width: double.infinity,
            child: Column(
              // The splash is a centred lockup: mark, wordmark and tagline all
              // share one vertical axis regardless of text direction.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 5),
                const HifzLogo(size: 110),
                SizedBox(height: AppDimens.lg.h),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pageTitle.copyWith(
                    fontFamily: AppTextStyles.latinFont,
                    fontSize: 30.sp,
                  ),
                ),
                SizedBox(height: AppDimens.xs.h),
                Text(
                  AppStrings.tagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pageSubtitle,
                ),
                const Spacer(flex: 5),
                const _PageDots(count: 3, active: 0),
                SizedBox(height: AppDimens.xl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The three-dot indicator at the foot of the splash sequence, with the active
/// dot drawn as a short pill. Shrink-wraps so the parent column centres it.
class _PageDots extends StatelessWidget {
  final int count;
  final int active;

  const _PageDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++)
          Container(
            width: i == active ? 22.w : 9.w,
            height: 9.w,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: i == active ? AppColors.primary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
      ],
    );
  }
}
