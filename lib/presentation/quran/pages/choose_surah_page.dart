import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/app_search_field.dart';
import '../../../core/ui/widgets/empty_state.dart';
import '../../../core/ui/widgets/page_header.dart';
import 'surah_reader_page.dart';
import '../bloc/quran_bloc.dart';
import '../widgets/surah_list_tile.dart';

/// Screen 09 — "اختر السورة". Lists all 114 surahs with search (T037/T038).
class ChooseSurahPage extends StatelessWidget {
  final bool showAppBar;
  const ChooseSurahPage({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranBloc>()..add(const SurahsRequested()),
      child: _ChooseSurahView(showAppBar: showAppBar),
    );
  }
}

class _ChooseSurahView extends StatelessWidget {
  final bool showAppBar;
  const _ChooseSurahView({required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<QuranBloc>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar ? AppBar() : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimens.lg.h),
              const PageHeader(
                title: 'اختر السورة',
                subtitle: 'اختاري سورة لبدء تحدياتها',
              ),
              SizedBox(height: AppDimens.lg.h),
              AppSearchField(
                hint: 'ابحثي عن سورة...',
                onChanged: (v) => bloc.add(SurahSearchChanged(v)),
              ),
              SizedBox(height: AppDimens.md.h),
              Expanded(
                child: BlocBuilder<QuranBloc, QuranState>(
                  builder: (context, state) {
                    if (state.status == UIStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == UIStatus.error) {
                      return Center(
                        child: Text(state.message, style: AppTextStyles.body),
                      );
                    }
                    final surahs = state.surahs;
                    if (surahs.isEmpty) {
                      return const EmptyState(
                        title: 'لا توجد نتائج',
                        message: 'جرّبي اسمًا آخر أو رقم السورة',
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: AppDimens.lg.h),
                      itemCount: surahs.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppDimens.sm.h),
                      itemBuilder: (context, i) => SurahListTile(
                        surah: surahs[i],
                        highlighted: i == 0,
                        // Reading is the primary action; the reader keeps
                        // "تدرّب" one tap away for the challenge hub.
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SurahReaderPage(surah: surahs[i]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
