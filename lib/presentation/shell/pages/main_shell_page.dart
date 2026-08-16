import 'package:flutter/material.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/widgets/app_bottom_nav.dart';
import '../../../core/ui/widgets/empty_state.dart';
import '../../quran/pages/choose_surah_page.dart';
import '../../revision/pages/revision_plan_page.dart';

/// The 5-tab bottom-navigation shell (T032), using the label-only navigation
/// from the refreshed exports:
///   الرئيسية (Home) · الخريطة (Hifz Map) · السور (Surahs) ·
///   التقدم (Progress) · حسابي (Profile)
///
/// السور and التقدم are wired to their features; the remaining tabs show the
/// shared empty state until their screens land.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const List<String> _labels = [
    'الرئيسية',
    'الخريطة',
    'السور',
    'التقدم',
    'حسابي',
  ];

  static const Map<int, String> _placeholderMessage = {
    0: 'لوحة تقدّمك اليومية قادمة قريبًا',
    1: 'خريطة الأجزاء قيد الإعداد',
    4: 'ملفك الشخصي وإعداداتك قيد الإعداد',
  };

  Widget _body(int index) {
    if (index == 2) return const ChooseSurahPage();
    if (index == 3) return const RevisionPlanPage();
    return EmptyState(
      title: _labels[index],
      message: _placeholderMessage[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _body(_index),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        labels: _labels,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
