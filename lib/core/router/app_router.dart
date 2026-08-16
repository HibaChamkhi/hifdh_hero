import 'package:flutter/material.dart';
import '../../presentation/auth/pages/forgot_password_page.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/auth/pages/register_page.dart';
import '../../presentation/onboarding/pages/start_journey_page.dart';
import '../../presentation/shell/pages/main_shell_page.dart';
import '../../presentation/splash/pages/splash_page.dart';

/// Centralized named routes (T004). Simple onGenerateRoute; swap for go_router
/// later if deep-linking is needed. Parameterized pages (challenge play, surah
/// challenges) are pushed directly with MaterialPageRoute.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashPage());
      case AppRoutes.onboarding:
        return _page(const StartJourneyPage());
      case AppRoutes.login:
        return _page(const LoginPage());
      case AppRoutes.register:
        return _page(const RegisterPage());
      case AppRoutes.forgotPassword:
        return _page(const ForgotPasswordPage());
      case AppRoutes.home:
        return _page(const MainShellPage());
      default:
        return _page(
          const Scaffold(body: Center(child: Text('المسار غير موجود'))),
        );
    }
  }

  static MaterialPageRoute _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);
}
