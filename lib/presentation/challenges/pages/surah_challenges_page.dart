import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/app_progress_bar.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../domain/challenges/models/challenge_type.dart';
import '../../../domain/quran/models/surah.dart';
import '../widgets/challenge_type_card.dart';
import 'challenge_play_page.dart';

/// Screen 14 — "تحديات السورة". Pick a challenge for the chosen surah.
class SurahChallengesPage extends StatelessWidget {
  final Surah surah;

  /// 0..1 memorisation progress for this surah. Wired to real data once
  /// per-surah progress lands (T092); the mock shows 85%.
  final double progress;

  const SurahChallengesPage({
    super.key,
    required this.surah,
    this.progress = 0,
  });

  static const _recommended = ChallengeType.completeAyah;

  void _start(BuildContext context, ChallengeType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallengePlayPage(
          type: type,
          surahNumber: surah.number,
          surahName: surah.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = ChallengeType.values;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppDimens.xs.h),
                Breadcrumb(
                  label: 'اختر السورة ›',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                SizedBox(height: AppDimens.sm.h),
                _SurahHeaderCard(surah: surah, progress: progress),
                SizedBox(height: AppDimens.xl.h),
                const SectionHeader.strong(title: 'اختاري تحديًا'),
                SizedBox(height: AppDimens.sm.h),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppDimens.sm.h,
                  crossAxisSpacing: AppDimens.sm.w,
                  childAspectRatio: 0.98,
                  children: [
                    for (final t in types)
                      ChallengeTypeCard(
                        type: t,
                        onTap: () => _start(context, t),
                      ),
                  ],
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'ابدأ التحدي الموصى به',
                  onPressed: () => _start(context, _recommended),
                ),
                SizedBox(height: AppDimens.lg.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The mint card at the top of the hub: surah name, meta, progress bar and the
/// "85% محفوظة" read-out — all reading from the right.
class _SurahHeaderCard extends StatelessWidget {
  final Surah surah;
  final double progress;

  const _SurahHeaderCard({required this.surah, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.lg.w,
        vertical: AppDimens.lg.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'سورة ${surah.name}',
            textAlign: TextAlign.right,
            style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
          ),
          SizedBox(height: AppDimens.xxs.h),
          Text(
            '${surah.ayahCount} آية · ${surah.revelationType.arabicLabel}',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
          ),
          SizedBox(height: AppDimens.md.h),
          AppProgressBar(
            value: progress,
            color: AppColors.primary,
            trackColor: AppColors.mintStrong,
          ),
          SizedBox(height: AppDimens.sm.h),
          Text(
            '${(progress * 100).round()}% محفوظة',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
