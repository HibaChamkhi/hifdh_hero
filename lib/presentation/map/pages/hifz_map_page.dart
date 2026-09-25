import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../domain/progress/models/juz_progress.dart';
import '../../progress/bloc/progress_bloc.dart';

/// Screen 08 — the الخريطة tab: the 30 ajza' as a vertical path running from
/// جزء عمّ downwards, each node showing how much of that juz is memorized.
class HifzMapPage extends StatelessWidget {
  const HifzMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgressBloc>()..add(const ProgressRequested()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView();

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
        final juz = state.progress.juz;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppDimens.lg.h),
                    const PageHeader(
                      title: AppStrings.hifzMap,
                      subtitle: AppStrings.hifzMapSubtitle,
                    ),
                    SizedBox(height: AppDimens.lg.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                left: AppDimens.screenH.w,
                right: AppDimens.screenH.w,
                bottom: AppDimens.xl.h,
              ),
              sliver: SliverList.builder(
                itemCount: juz.length,
                itemBuilder: (context, i) => _MapNode(
                  progress: juz[i],
                  // The path is drawn as a connector above and below each
                  // node, so the ends stay open.
                  isFirst: i == 0,
                  isLast: i == juz.length - 1,
                  // A juz opens once the one before it on the path is done.
                  locked: i > 0 && !juz[i - 1].isComplete,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One stop on the path: the label on the reading side, the node on the
/// trailing side with the connector line running through it.
class _MapNode extends StatelessWidget {
  final JuzProgress progress;
  final bool isFirst;
  final bool isLast;
  final bool locked;

  const _MapNode({
    required this.progress,
    required this.isFirst,
    required this.isLast,
    required this.locked,
  });

  static const double _nodeSize = 76;

  @override
  Widget build(BuildContext context) {
    final complete = progress.isComplete;
    final Color labelColor = locked
        ? AppColors.textTertiary
        : AppColors.textPrimary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                progress.juz.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(color: labelColor),
              ),
            ),
          ),
          SizedBox(width: AppDimens.md.w),
          SizedBox(
            width: _nodeSize.w,
            child: Column(
              children: [
                _Connector(visible: !isFirst),
                _Node(progress: progress, locked: locked, complete: complete),
                _Connector(visible: !isLast),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The hairline that joins consecutive nodes.
class _Connector extends StatelessWidget {
  final bool visible;

  const _Connector({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          width: 1.4.w,
          constraints: BoxConstraints(minHeight: AppDimens.lg.h),
          color: visible ? AppColors.border : Colors.transparent,
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  final JuzProgress progress;
  final bool locked;
  final bool complete;

  const _Node({
    required this.progress,
    required this.locked,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = complete
        ? AppColors.primary
        : locked
        ? AppColors.surface
        : AppColors.surfaceElevated;
    return Container(
      width: _MapNode._nodeSize.w,
      height: _MapNode._nodeSize.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(
          color: complete
              ? AppColors.primary
              : locked
              ? AppColors.border
              : AppColors.primary,
          width: complete ? 0 : 2,
        ),
      ),
      child: complete
          ? Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.onPrimary,
              size: 34.sp,
            )
          : Text(
              '${progress.percent}%',
              style: AppTextStyles.bodyStrong.copyWith(
                fontFamily: AppTextStyles.latinFont,
                color: locked ? AppColors.textTertiary : AppColors.primary,
              ),
            ),
    );
  }
}
