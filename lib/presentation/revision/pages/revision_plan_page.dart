import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/empty_state.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/stat_tile.dart';
import '../../../domain/revision/models/revision_item.dart';
import '../../../domain/revision/models/revision_plan.dart';
import '../bloc/revision_bloc.dart';
import '../widgets/ayah_review_sheet.dart';
import 'revision_history_page.dart';
import 'weak_ayahs_page.dart';

/// Screen 28 — "توصية اليوم" (today's recommended review).
/// Hosted by the التقدم tab; opens weak-ayahs and history.
class RevisionPlanPage extends StatelessWidget {
  const RevisionPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RevisionBloc>()..add(const RevisionRequested()),
      child: const _PlanView(),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView();

  Future<void> _startSmartReview(
    BuildContext context,
    RevisionBloc bloc,
    RevisionPlan plan,
  ) async {
    for (final item in List.of(plan.items)) {
      final res = await showAyahReviewSheet(context, item);
      if (res == null) break;
      bloc.add(
        ReviewGraded(
          surahNumber: item.surahNumber,
          ayahNumber: item.ayahNumber,
          correct: res,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  void _open(BuildContext context, RevisionBloc bloc, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: bloc, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (context, state) {
            if (state.status == UIStatus.loading ||
                state.status == UIStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            final bloc = context.read<RevisionBloc>();
            final plan = state.plan;
            // A long due-list plus the two action rows can outgrow a short
            // viewport; scroll rather than overflow, while keeping the button
            // pinned to the bottom whenever there is slack.
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppDimens.lg.h),
                        const PageHeader(
                          title: 'توصية اليوم',
                          subtitle: 'بناءً على ما يحتاج تركيزًا اليوم',
                        ),
                        SizedBox(height: AppDimens.lg.h),
                        if (plan.isEmpty)
                          const Expanded(
                            child: EmptyState(
                              title: 'لا توجد مراجعات مستحقة اليوم',
                              message: 'أحسنتِ — عودي غدًا لمتابعة خطتك',
                            ),
                          )
                        else ...[
                          ...plan.items
                              .take(5)
                              .map(
                                (item) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: AppDimens.sm.h,
                                  ),
                                  child: _DueRow(item: item),
                                ),
                              ),
                          SizedBox(height: AppDimens.xs.h),
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  value: '${plan.ayahCount} آيات',
                                  label: 'عدد الآيات',
                                  latinValue: false,
                                ),
                              ),
                              SizedBox(width: AppDimens.sm.w),
                              Expanded(
                                child: StatTile(
                                  value: '${plan.estimatedMinutes} دقائق',
                                  label: 'الوقت المقدر',
                                  latinValue: false,
                                  valueColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    _open(context, bloc, const WeakAyahsPage()),
                                child: Text(
                                  'الآيات الضعيفة',
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => _open(
                                  context,
                                  bloc,
                                  const RevisionHistoryPage(),
                                ),
                                child: Text(
                                  'سجل المراجعة',
                                  style: AppTextStyles.bodyStrong.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimens.sm.h),
                        PrimaryButton(
                          label: 'ابدأ المراجعة الذكية',
                          enabled: !plan.isEmpty,
                          onPressed: () =>
                              _startSmartReview(context, bloc, plan),
                        ),
                        SizedBox(height: AppDimens.lg.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A single due-ayah row: rose pill, bullet at the start (right in RTL).
class _DueRow extends StatelessWidget {
  final RevisionItem item;
  const _DueRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.rowHeight.h,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
      decoration: BoxDecoration(
        color: AppColors.rose,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm.r),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: AppColors.roseText,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppDimens.sm.w),
          Expanded(
            child: Text(
              '${item.surahName}، الآية ${item.ayahNumber}',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.roseText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
