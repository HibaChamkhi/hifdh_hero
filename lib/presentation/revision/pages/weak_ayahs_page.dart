import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/widgets/empty_state.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/utils/day.dart';
import '../bloc/revision_bloc.dart';
import '../widgets/ayah_review_sheet.dart';
import '../widgets/weak_ayah_card.dart';

/// Screen 31 — "المراجعة الموصى بها" (weak ayahs needing extra focus).
class WeakAyahsPage extends StatelessWidget {
  const WeakAyahsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = Day.today();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<RevisionBloc, RevisionState>(
          builder: (context, state) {
            if (state.status == UIStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final bloc = context.read<RevisionBloc>();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PageHeader(
                    title: 'المراجعة الموصى بها',
                    subtitle: 'آيات تحتاج تركيزًا إضافيًا',
                  ),
                  SizedBox(height: AppDimens.lg.h),
                  if (state.weak.isEmpty)
                    const Expanded(
                      child: EmptyState(
                        title: 'لا توجد آيات ضعيفة',
                        message: 'ممتاز — حفظك ثابت هذا الأسبوع',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: AppDimens.lg.h),
                        itemCount: state.weak.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppDimens.md.h),
                        itemBuilder: (context, i) {
                          final item = state.weak[i];
                          return WeakAyahCard(
                            item: item,
                            today: today,
                            onReview: () async {
                              final res =
                                  await showAyahReviewSheet(context, item);
                              if (res != null) {
                                bloc.add(ReviewGraded(
                                  surahNumber: item.surahNumber,
                                  ayahNumber: item.ayahNumber,
                                  correct: res,
                                ));
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
