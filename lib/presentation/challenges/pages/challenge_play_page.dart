import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/app_progress_bar.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../domain/challenges/models/challenge_type.dart';
import '../bloc/challenge_bloc.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_prompt_card.dart';
import 'challenge_result_page.dart';

/// MCQ play screen (screens 15/16/20/23).
class ChallengePlayPage extends StatelessWidget {
  final ChallengeType type;
  final int surahNumber;
  final String surahName;

  const ChallengePlayPage({
    super.key,
    required this.type,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChallengeBloc>()
        ..add(ChallengeStarted(type: type, surahNumber: surahNumber)),
      child: _PlayView(type: type, surahName: surahName),
    );
  }
}

class _PlayView extends StatelessWidget {
  final ChallengeType type;
  final String surahName;
  const _PlayView({required this.type, required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ChallengeBloc, ChallengeState>(
          listenWhen: (p, c) => c.finished && c.result != null,
          listener: (context, state) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ChallengeResultPage(result: state.result!),
              ),
            );
          },
          builder: (context, state) {
            if (state.status == UIStatus.loading ||
                state.status == UIStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == UIStatus.error) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.lg.w),
                  child: Text(state.message,
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                ),
              );
            }
            final q = state.current;
            if (q == null) {
              return const SizedBox.shrink();
            }
            final bloc = context.read<ChallengeBloc>();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppDimens.xs.h),
                  Breadcrumb(label: 'سورة $surahName · تحديات السورة'),
                  SizedBox(height: AppDimens.xs.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${state.position} / ${state.total}',
                        style: AppTextStyles.caption.copyWith(
                          fontFamily: AppTextStyles.latinFont,
                        ),
                      ),
                      const Spacer(),
                      Text(type.arabicLabel, style: AppTextStyles.pageTitle),
                    ],
                  ),
                  SizedBox(height: AppDimens.sm.h),
                  SegmentedProgress(
                    total: state.total,
                    completed: state.position,
                  ),
                  SizedBox(height: AppDimens.lg.h),
                  QuestionPromptCard(
                    text: q.prompt,
                    subtitle: q.promptSubtitle,
                  ),
                  SizedBox(height: AppDimens.lg.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(type.instruction, style: AppTextStyles.caption),
                  ),
                  SizedBox(height: AppDimens.sm.h),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(bottom: AppDimens.sm.h),
                      itemCount: q.options.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppDimens.sm.h),
                      itemBuilder: (context, i) => OptionTile(
                        label: q.options[i],
                        selected: state.selectedIndex == i,
                        onTap: () => bloc.add(OptionSelected(i)),
                      ),
                    ),
                  ),
                  PrimaryButton(
                    label: state.isLast ? 'إنهاء' : 'متابعة',
                    enabled: state.selectedIndex != null,
                    onPressed: () => bloc.add(const AnswerSubmitted()),
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
