import 'package:flutter/material.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/widgets/app_bottom_nav.dart';
import '../../home/pages/home_page.dart';
import '../../map/pages/hifz_map_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../quran/pages/choose_surah_page.dart';
import '../../revision/pages/revision_plan_page.dart';

/// The 5-tab bottom-navigation shell (T032):
///   الرئيسية (Home) · الخريطة (Hifz Map) · السور (Surahs) ·
///   التقدم (Progress) · حسابي (Profile)
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const List<AppNavItem> _tabs = [
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
    AppNavItem(
      label: 'السور',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
    AppNavItem(
      label: 'التقدم',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
    ),
    AppNavItem(
      label: 'حسابي',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  /// Index of the التقدم tab — where "متابعة التدريب" on the home screen
  /// hands the user off to today's review.
  static const int _practiceTab = 3;

  Widget _body(int index) {
    switch (index) {
      case 0:
        return HomePage(
          onContinueTraining: () => setState(() => _index = _practiceTab),
        );
      case 1:
        return const HifzMapPage();
      case 2:
        return const ChooseSurahPage();
      case 3:
        return const RevisionPlanPage();
      default:
        return const ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _body(_index)),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        items: _tabs,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
