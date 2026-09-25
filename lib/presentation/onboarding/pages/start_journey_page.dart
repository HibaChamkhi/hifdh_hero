import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/widgets/choice_chip_tag.dart';
import '../../../core/ui/widgets/hifz_logo.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../bloc/onboarding_bloc.dart';
import '../../quran/pages/select_surahs_page.dart';
import '../widgets/level_option.dart';

/// Screen 02 — "ابدأ رحلة حفظك".
class StartJourneyPage extends StatelessWidget {
  const StartJourneyPage({super.key});

  // A small starter set of surahs for the chips (surahNumber : arabicName).
  static const Map<int, String> _commonSurahs = {
    1: 'الفاتحة',
    112: 'الإخلاص',
    114: 'الناس',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>()..add(const OnboardingStarted()),
      child: const _StartJourneyView(),
    );
  }
}

class _StartJourneyView extends StatelessWidget {
  const _StartJourneyView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == UIStatus.success && state.profile.completed) {
          // New users continue to account creation (screen 05).
          Navigator.of(context).pushReplacementNamed(AppRoutes.register);
        } else if (state.status == UIStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<OnboardingBloc>();
        final profile = state.profile;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            // Short screens scroll; taller ones keep the button pinned to the
            // bottom via the `Spacer` below.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppDimens.lg.h),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: HifzLogo(size: 60),
                        ),
                        SizedBox(height: AppDimens.xl.h),
                        const PageHeader(
                          title: AppStrings.startJourney,
                          subtitle: AppStrings.startJourneySubtitle,
                        ),
                        SizedBox(height: AppDimens.xl.h),
                        const SectionHeader(
                          title: AppStrings.memorizationLevel,
                        ),
                        SizedBox(height: AppDimens.sm.h),
                        LevelOption(
                          label: AppStrings.levelBeginner,
                          selected: profile.level == MemorizationLevel.beginner,
                          onTap: () => bloc.add(
                            const LevelSelected(MemorizationLevel.beginner),
                          ),
                        ),
                        SizedBox(height: AppDimens.sm.h),
                        LevelOption(
                          label: AppStrings.levelIntermediate,
                          selected:
                              profile.level == MemorizationLevel.intermediate,
                          onTap: () => bloc.add(
                            const LevelSelected(MemorizationLevel.intermediate),
                          ),
                        ),
                        SizedBox(height: AppDimens.sm.h),
                        LevelOption(
                          label: AppStrings.levelHafiz,
                          selected: profile.level == MemorizationLevel.hafiz,
                          onTap: () => bloc.add(
                            const LevelSelected(MemorizationLevel.hafiz),
                          ),
                        ),
                        SizedBox(height: AppDimens.xl.h),
                        const SectionHeader(title: AppStrings.memorizedSurahs),
                        SizedBox(height: AppDimens.sm.h),
                        Wrap(
                          // RTL: `start` packs each run against the right edge.
                          alignment: WrapAlignment.start,
                          spacing: AppDimens.sm.w,
                          runSpacing: AppDimens.sm.h,
                          children: [
                            for (final entry
                                in StartJourneyPage._commonSurahs.entries)
                              ChoiceChipTag(
                                label: entry.value,
                                selected: profile.memorized.startedSurahs
                                    .contains(entry.key),
                                onTap: () => bloc.add(SurahToggled(entry.key)),
                              ),
                            // The starter chips cover three surahs; this
                            // opens the full 114 so the answer isn't limited
                            // to whatever fits on the card.
                            ChoiceChipTag(
                              label: AppStrings.more,
                              dashed: true,
                              onTap: () async {
                                final chosen = await showSelectSurahs(
                                  context,
                                  profile.memorized,
                                );
                                if (chosen != null) {
                                  bloc.add(MemorizedSurahsChanged(chosen));
                                }
                              },
                            ),
                          ],
                        ),
                        // Minimum breathing room before the button on short
                        // screens; `Spacer` takes over when there is slack.
                        SizedBox(height: AppDimens.xl.h),
                        const Spacer(),
                        PrimaryButton(
                          label: AppStrings.startMyJourney,
                          loading: state.status == UIStatus.loading,
                          onPressed: () =>
                              bloc.add(const OnboardingSubmitted()),
                        ),
                        SizedBox(height: AppDimens.lg.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
