import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/app_progress_bar.dart';
import '../../../core/ui/widgets/diamond_mark.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../domain/progress/models/juz_progress.dart';
import '../../../domain/progress/models/user_progress.dart';
import '../../progress/bloc/progress_bloc.dart';

/// Screen 07 — the الرئيسية tab: greeting, streak ring, the two headline
/// stats, the juz journey card and the continue-training call to action.
class HomePage extends StatelessWidget {
  /// Sends the user on to the practice tab; supplied by the shell.
  final VoidCallback onContinueTraining;

  const HomePage({super.key, required this.onContinueTraining});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgressBloc>()..add(const ProgressRequested()),
      child: _HomeView(onContinueTraining: onContinueTraining),
    );
  }
}

class _HomeView extends StatelessWidget {
  final VoidCallback onContinueTraining;

  const _HomeView({required this.onContinueTraining});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        if (state.status == UIStatus.loading ||
            state.status == UIStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == UIStatus.error) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.lg.w),
              child: Text(state.message, style: AppTextStyles.body),
            ),
          );
        }
        final p = state.progress;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimens.lg.h),
              _Header(name: p.name, streak: p.currentStreak),
              SizedBox(height: AppDimens.lg.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _ExploredCard(progress: p)),
                    SizedBox(width: AppDimens.sm.w),
                    Expanded(
                      flex: 2,
                      child: _StreakCard(streak: p.currentStreak),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimens.lg.h),
              _JourneyCard(juz: p.juz),
              SizedBox(height: AppDimens.lg.h),
              PrimaryButton(
                label: AppStrings.continueTraining,
                onPressed: onContinueTraining,
              ),
              SizedBox(height: AppDimens.lg.h),
            ],
          ),
        );
      },
    );
  }
}

/// Greeting on the reading side, streak ring opposite it.
class _Header extends StatelessWidget {
  final String name;
  final int streak;

  const _Header({required this.name, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.greeting,
                style: AppTextStyles.pageSubtitle,
              ),
              if (name.isNotEmpty) ...[
                SizedBox(height: AppDimens.xxs.h),
                Text(name, style: AppTextStyles.h1),
              ],
            ],
          ),
        ),
        _StreakRing(streak: streak),
      ],
    );
  }
}

/// The terracotta ring showing the current streak in days.
class _StreakRing extends StatelessWidget {
  final int streak;

  const _StreakRing({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.terracotta, width: 1.6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$streak',
            style: AppTextStyles.statNumber.copyWith(
              fontFamily: AppTextStyles.latinFont,
              fontSize: 22.sp,
              color: AppColors.terracotta,
            ),
          ),
          Text(
            AppStrings.dayUnit,
            style: AppTextStyles.statLabel.copyWith(
              color: AppColors.terracotta,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mint card: ayahs explored, with the share of the schedule covered so far.
class _ExploredCard extends StatelessWidget {
  final UserProgress progress;

  const _ExploredCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.md.w),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.exploredAyahs,
            style: AppTextStyles.statLabel.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: AppDimens.xs.h),
          Text(
            '${progress.exploredAyahs}',
            style: AppTextStyles.statNumber.copyWith(
              fontFamily: AppTextStyles.latinFont,
              fontSize: 30.sp,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: AppDimens.sm.h),
          AppProgressBar(
            value: progress.exploredRatio,
            color: AppColors.primary,
            trackColor: AppColors.borderStrong,
            height: 8,
          ),
        ],
      ),
    );
  }
}

/// Peach card mirroring the ring — the streak as a headline figure.
class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.md.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$streak',
            style: AppTextStyles.statNumber.copyWith(
              fontFamily: AppTextStyles.latinFont,
              fontSize: 30.sp,
              color: AppColors.terracotta,
            ),
          ),
          SizedBox(height: AppDimens.xxs.h),
          Text(
            AppStrings.streakDays,
            style: AppTextStyles.statLabel.copyWith(
              color: AppColors.terracotta,
            ),
          ),
        ],
      ),
    );
  }
}

/// "رحلة حفظك" — the juz the user is working through, most advanced first.
class _JourneyCard extends StatelessWidget {
  final List<JuzProgress> juz;

  const _JourneyCard({required this.juz});

  @override
  Widget build(BuildContext context) {
    // Only the juz the user has actually touched belong here; the full list
    // lives on the map tab.
    final started = juz.where((j) => j.isStarted).take(3).toList();
    if (started.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(AppDimens.md.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppStrings.yourJourney,
            textAlign: TextAlign.right,
            style: AppTextStyles.h3,
          ),
          SizedBox(height: AppDimens.md.h),
          for (final j in started) ...[
            _JuzRow(progress: j),
            if (j != started.last) SizedBox(height: AppDimens.md.h),
          ],
        ],
      ),
    );
  }
}

class _JuzRow extends StatelessWidget {
  final JuzProgress progress;

  const _JuzRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DiamondMark(size: 14, filled: progress.isComplete),
            SizedBox(width: AppDimens.xs.w),
            Expanded(
              child: Text(progress.juz.name, style: AppTextStyles.bodyStrong),
            ),
            Text(
              '${progress.percent}%',
              style: AppTextStyles.bodyStrong.copyWith(
                fontFamily: AppTextStyles.latinFont,
                color: progress.isComplete
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.xs.h),
        AppProgressBar(
          value: progress.ratio,
          color: progress.isComplete ? AppColors.primary : AppColors.primaryMid,
          trackColor: AppColors.border,
          height: 8,
        ),
      ],
    );
  }
}
