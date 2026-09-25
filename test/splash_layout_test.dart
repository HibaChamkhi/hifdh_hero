import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/constants/app_strings.dart';
import 'package:hifdh_hero/core/di/injection.dart';
import 'package:hifdh_hero/core/ui/widgets/hifz_logo.dart';
import 'package:hifdh_hero/domain/auth/repositories/auth_repository.dart';
import 'package:hifdh_hero/domain/onboarding/models/onboarding_profile.dart';
import 'package:hifdh_hero/domain/onboarding/repositories/onboarding_repository.dart';
import 'package:hifdh_hero/presentation/splash/pages/splash_page.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> completeOnboarding() async {}
  @override
  OnboardingProfile getProfile() => const OnboardingProfile();
  @override
  bool isOnboardingComplete() => false;
  @override
  Future<void> saveProfile(OnboardingProfile profile) async {}
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  bool get isLoggedIn => false;
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register(Map<String, dynamic> userInfo) async {}
}

void main() {
  setUp(() {
    getIt
      ..registerSingleton<OnboardingRepository>(_FakeOnboardingRepository())
      ..registerSingleton<AuthRepository>(_FakeAuthRepository());
  });

  tearDown(getIt.reset);

  testWidgets('splash lockup is horizontally centred', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Splash redirects on a timer; land it on a blank page so this stays
          // a layout test and doesn't drag in the destination's dependencies.
          home: const SplashPage(),
          onGenerateRoute: (_) =>
              MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
        ),
      ),
    );
    // Settle the first frame without running out the 1500ms redirect timer.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SplashPage), findsOneWidget);
    final screen = tester.getRect(find.byType(SplashPage));
    final targets = <String, Finder>{
      'logo': find.byType(HifzLogo),
      'wordmark': find.text(AppStrings.appName),
      'tagline': find.text(AppStrings.tagline),
      'page dots': find.byType(Row),
    };
    targets.forEach((name, finder) {
      expect(
        tester.getRect(finder).center.dx,
        moreOrLessEquals(screen.center.dx, epsilon: 0.5),
        reason: 'the $name should sit on the screen\'s vertical axis',
      );
    });

    // Let the redirect fire so no timer outlives the test.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
