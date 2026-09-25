import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/stat_tile.dart';
import '../../../domain/auth/repositories/auth_repository.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../../../domain/progress/models/user_progress.dart';
import '../../progress/bloc/progress_bloc.dart';
import '../widgets/profile_avatar.dart';
import 'edit_profile_page.dart';

/// Screen 11 — the حسابي tab: who the user is, the three headline numbers,
/// and the way back out of the account.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProgressBloc>()..add(const ProgressRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  static const Map<MemorizationLevel, String> _levelLabels = {
    MemorizationLevel.beginner: AppStrings.levelBeginner,
    MemorizationLevel.intermediate: AppStrings.levelIntermediate,
    MemorizationLevel.hafiz: AppStrings.levelHafiz,
  };

  /// Reloads on return so a saved name, photo or surah count shows straight
  /// away rather than on the next visit to the tab.
  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<ProgressBloc>();
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const EditProfilePage()));
    if (saved ?? false) bloc.add(const ProgressRequested());
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<AuthRepository>().logout();
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.genericError)),
      );
    }
  }

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
              SizedBox(height: AppDimens.md.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () => _edit(context),
                  icon: Icon(Icons.edit_outlined, size: 18.sp),
                  label: const Text(AppStrings.editProfileAction),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.xs.h),
              Center(
                child: ProfileAvatar(
                  name: p.name,
                  imagePath: p.avatarPath,
                  size: 96,
                ),
              ),
              SizedBox(height: AppDimens.md.h),
              Text(
                p.name.isEmpty ? AppStrings.profileTitle : p.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              SizedBox(height: AppDimens.xxs.h),
              Text(
                _levelLabels[p.level] ?? AppStrings.levelBeginner,
                textAlign: TextAlign.center,
                style: AppTextStyles.pageSubtitle,
              ),
              SizedBox(height: AppDimens.lg.h),
              _StatRow(progress: p),
              SizedBox(height: AppDimens.xl.h),
              TextButton(
                onPressed: () => _logout(context),
                child: Text(
                  AppStrings.logout,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.lg.h),
            ],
          ),
        );
      },
    );
  }
}

/// Streak · XP · surahs, in the design's order (reading right to left).
class _StatRow extends StatelessWidget {
  final UserProgress progress;

  const _StatRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatTile(
              value: '${progress.memorizedSurahs}',
              label: AppStrings.surahUnit,
            ),
          ),
          SizedBox(width: AppDimens.sm.w),
          Expanded(
            child: StatTile(
              value: '${progress.xp}',
              label: AppStrings.xpPoints,
              valueColor: AppColors.primary,
            ),
          ),
          SizedBox(width: AppDimens.sm.w),
          Expanded(
            child: StatTile(
              value: '${progress.currentStreak}',
              label: AppStrings.streakDays,
              valueColor: AppColors.terracotta,
            ),
          ),
        ],
      ),
    );
  }
}
