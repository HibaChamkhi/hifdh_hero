import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/stat_tile.dart';
import '../bloc/revision_bloc.dart';
import '../widgets/review_heatmap.dart';

/// Screen 32 — "سجل المراجعة" (review calendar + streaks).
class RevisionHistoryPage extends StatelessWidget {
  const RevisionHistoryPage({super.key});

  /// Gregorian month names in Arabic. Hard-coded rather than using
  /// `DateFormat.yMMMM('ar')`, which needs `initializeDateFormatting` at boot.
  static const List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String month = '${_months[now.month - 1]} ${now.year}';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (context, state) {
            final h = state.history;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(title: 'سجل المراجعة', subtitle: month),
                  SizedBox(height: AppDimens.lg.h),
                  ReviewHeatmap(history: h),
                  SizedBox(height: AppDimens.lg.h),
                  // RTL: أيام هذا الشهر on the right, أطول سلسلة on the left.
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          value: '${h.daysThisMonth}',
                          label: 'أيام هذا الشهر',
                        ),
                      ),
                      SizedBox(width: AppDimens.sm.w),
                      Expanded(
                        child: StatTile(
                          value: '${h.longestStreak}',
                          label: 'أطول سلسلة',
                          valueColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.lg.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
