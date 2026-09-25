import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hifdh_hero/core/ui/widgets/page_header.dart';
import 'package:hifdh_hero/core/ui/widgets/hifz_logo.dart';
import 'package:hifdh_hero/presentation/auth/widgets/auth_logo.dart';
import 'package:hifdh_hero/presentation/auth/widgets/auth_text_field.dart';

/// Under the app's Arabic locale everything renders RTL, so any label that
/// leads its column must sit against the RIGHT edge of the available width.
Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, __) => MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Padding(padding: EdgeInsets.zero, child: child),
    ),
  ),
);

void main() {
  testWidgets('AuthTextField label hugs the right edge in RTL', (tester) async {
    await tester.pumpWidget(
      _host(
        AuthTextField(
          label: 'الاسم الكامل',
          controller: TextEditingController(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final label = tester.getRect(find.text('الاسم الكامل'));
    final field = tester.getRect(find.byType(TextFormField));
    expect(label.right, moreOrLessEquals(field.right, epsilon: 1.0));
    expect(label.left, greaterThan(field.center.dx));
  });

  testWidgets('AuthLogo centres itself horizontally', (tester) async {
    await tester.pumpWidget(
      _host(const SizedBox(width: 400, child: AuthLogo())),
    );
    await tester.pumpAndSettle();

    final box = tester.getRect(find.byType(SizedBox).first);
    final logo = tester.getRect(find.byType(HifzLogo));
    expect(logo.center.dx, moreOrLessEquals(box.center.dx, epsilon: 0.5));
  });

  testWidgets('PageHeader title and subtitle hug the right edge in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 400,
          child: PageHeader(title: 'ابدأ رحلة حفظك', subtitle: 'اختر مستواك'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.getRect(find.byType(SizedBox).first);
    for (final text in ['ابدأ رحلة حفظك', 'اختر مستواك']) {
      final rect = tester.getRect(find.text(text));
      expect(
        rect.right,
        moreOrLessEquals(box.right, epsilon: 1.0),
        reason: '"$text" should be flush right',
      );
    }
  });
}
