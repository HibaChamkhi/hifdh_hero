import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/ui/styles/colors.dart';
import 'package:hifdh_hero/core/ui/widgets/app_bottom_nav.dart';

const _tabs = [
  AppNavItem(
    label: 'الرئيسية',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  AppNavItem(
    label: 'الخريطة',
    icon: Icons.map_outlined,
    activeIcon: Icons.map_rounded,
  ),
];

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
    home: Scaffold(bottomNavigationBar: child),
  ),
);

void main() {
  testWidgets('every destination renders an icon above its label', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(AppBottomNav(currentIndex: 0, onTap: (_) {}, items: _tabs)),
    );
    await tester.pumpAndSettle();

    for (final tab in _tabs) {
      final label = find.text(tab.label);
      expect(label, findsOneWidget, reason: '${tab.label} label missing');
      final icon = find.byIcon(tab == _tabs.first ? tab.activeIcon : tab.icon);
      expect(icon, findsOneWidget, reason: '${tab.label} icon missing');
      // The icon sits above its label, not beside it.
      expect(tester.getCenter(icon).dy, lessThan(tester.getCenter(label).dy));
    }
  });

  testWidgets('the selected destination is filled and tinted green', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(AppBottomNav(currentIndex: 1, onTap: (_) {}, items: _tabs)),
    );
    await tester.pumpAndSettle();

    // Selected uses the filled variant, unselected the outlined one.
    expect(find.byIcon(Icons.map_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsNothing);

    final selected = tester.widget<Icon>(find.byIcon(Icons.map_rounded));
    final unselected = tester.widget<Icon>(find.byIcon(Icons.home_outlined));
    expect(selected.color, AppColors.primary);
    expect(unselected.color, AppColors.textSecondary);
  });

  testWidgets('tapping a destination reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _host(
        AppBottomNav(currentIndex: 0, onTap: (i) => tapped = i, items: _tabs),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('الخريطة'));
    await tester.pump();

    expect(tapped, 1);
  });
}
