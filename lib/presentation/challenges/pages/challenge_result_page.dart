import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/diamond_mark.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/stat_tile.dart';
import '../../../domain/challenges/models/challenge_result.dart';

/// Screen 24 — challenge result ("أحسنت!"). Reads from the right.
class ChallengeResultPage extends StatelessWidget {
  final ChallengeResult result;
  const ChallengeResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(flex: 4),
              const DiamondCluster(count: 3, size: 34),
              SizedBox(height: AppDimens.lg.h),
              Text(
                'أحسنت!',
                textAlign: TextAlign.right,
                style: AppTextStyles.pageTitle,
              ),
              SizedBox(height: AppDimens.lg.h),
              Text(
                '+${result.xp}',
                textAlign: TextAlign.right,
                style: AppTextStyles.statNumber.copyWith(
                  fontSize: 44.sp,
                  color: AppColors.terracotta,
                ),
              ),
              SizedBox(height: AppDimens.xxs.h),
              Text(
                'نقطة',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.terracotta),
              ),
              SizedBox(height: AppDimens.xl.h),
              // RTL: the row starts on the right — الوقت first, then الدقة.
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InlineStat(value: result.durationLabel, label: 'الوقت'),
                  SizedBox(width: AppDimens.xl.w),
                  InlineStat(
                    value: '${result.accuracyPercent}%',
                    label: 'الدقة',
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const Spacer(flex: 5),
              PrimaryButton(
                label: 'متابعة',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(height: AppDimens.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}
