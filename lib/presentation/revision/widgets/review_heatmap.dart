import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/utils/day.dart';
import '../../../domain/revision/models/revision_history.dart';

/// Month heatmap of review days (screen 32).
///
/// Reviewed days use the mid green; days that have already passed without a
/// review are tinted rose; future days stay neutral.
class ReviewHeatmap extends StatelessWidget {
  final RevisionHistory history;

  const ReviewHeatmap({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int todayNumber = Day.today();

    final cells = <Widget>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final dayNumber = Day.fromDateTime(DateTime.utc(now.year, now.month, d));
      final bool reviewed = history.reviewedOn(dayNumber);
      final bool past = dayNumber < todayNumber;

      final Color color = reviewed
          ? AppColors.primaryMid
          : (past ? AppColors.rose : AppColors.border);

      cells.add(
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radiusXs.r),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimens.xs.w,
      crossAxisSpacing: AppDimens.xs.w,
      children: cells,
    );
  }
}
