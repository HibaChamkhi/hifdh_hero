import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/profile/models/editable_profile.dart';
import '../../onboarding/widgets/level_option.dart';
import '../bloc/profile_edit_bloc.dart';
import '../widgets/profile_avatar.dart';
import '../../quran/pages/select_surahs_page.dart';

/// Screen 35 — "تعديل الملف الشخصي": photo, name, level and how much of the
/// Quran the user has memorized.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProfileEditBloc>()..add(const ProfileEditRequested()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _name = TextEditingController();

  /// Set once from the loaded profile; after that the field owns its text so
  /// typing doesn't fight the bloc's state stream.
  bool _nameSeeded = false;

  static const Map<MemorizationLevel, String> _levelLabels = {
    MemorizationLevel.beginner: AppStrings.levelBeginner,
    MemorizationLevel.intermediate: AppStrings.levelIntermediate,
    MemorizationLevel.hafiz: AppStrings.levelHafiz,
  };

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(BuildContext context, ProfileEditBloc bloc) async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text(AppStrings.takePhoto),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text(
                AppStrings.removePhoto,
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () => Navigator.of(sheetContext).pop(_PhotoAction.remove),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    if (source == _PhotoAction.remove) {
      bloc.add(const ProfileAvatarRemoved());
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(
        source: source == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        // Avatars render at ~96pt; anything larger is wasted storage.
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      bloc.add(ProfileAvatarPicked(picked.path));
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.photoFailed)),
      );
    }
  }

  Future<void> _openMemorizedSurahs(
    BuildContext context,
    ProfileEditBloc bloc,
    MemorizedAyahs current,
  ) async {
    final chosen = await showSelectSurahs(context, current);
    if (chosen != null) bloc.add(ProfileSurahsChanged(chosen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(AppStrings.editProfile),
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<ProfileEditBloc, ProfileEditState>(
          listener: (context, state) {
            if (state.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.profileSaved)),
              );
              Navigator.of(context).pop(true);
            } else if (state.status == UIStatus.error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state.status == UIStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            final bloc = context.read<ProfileEditBloc>();
            final profile = state.profile;
            if (!_nameSeeded) {
              _name.text = profile.name;
              _nameSeeded = true;
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppDimens.md.h),
                  _AvatarPicker(
                    profile: profile,
                    onTap: () => _pickPhoto(context, bloc),
                  ),
                  SizedBox(height: AppDimens.xl.h),
                  const Text(AppStrings.fullName, style: AppTextStyles.label),
                  SizedBox(height: AppDimens.xs.h),
                  TextField(
                    controller: _name,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                    cursorColor: AppColors.primary,
                    onChanged: (v) => bloc.add(ProfileNameChanged(v)),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppDimens.md.w,
                        vertical: AppDimens.md.h + 2,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimens.xl.h),
                  const SectionHeader(title: AppStrings.memorizationLevel),
                  SizedBox(height: AppDimens.sm.h),
                  for (final level in MemorizationLevel.values) ...[
                    LevelOption(
                      label: _levelLabels[level]!,
                      selected: profile.level == level,
                      onTap: () => bloc.add(ProfileLevelChanged(level)),
                    ),
                    SizedBox(height: AppDimens.sm.h),
                  ],
                  SizedBox(height: AppDimens.md.h),
                  const SectionHeader(title: AppStrings.memorizedSurahs),
                  SizedBox(height: AppDimens.sm.h),
                  _MemorizedSurahsRow(
                    memorized: profile.memorized,
                    onTap: () =>
                        _openMemorizedSurahs(context, bloc, profile.memorized),
                  ),
                  SizedBox(height: AppDimens.xl.h),
                  PrimaryButton(
                    label: AppStrings.saveChanges,
                    enabled: state.canSave,
                    loading: state.status == UIStatus.loading,
                    onPressed: () => bloc.add(const ProfileEditSubmitted()),
                  ),
                  if (!state.canSave) ...[
                    SizedBox(height: AppDimens.xs.h),
                    Text(
                      AppStrings.nameRequired,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
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

enum _PhotoAction { gallery, camera, remove }

/// The avatar with a camera badge, tappable to change the picture.
class _AvatarPicker extends StatelessWidget {
  final EditableProfile profile;
  final VoidCallback onTap;

  const _AvatarPicker({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ProfileAvatar(
                  imagePath: profile.avatarPath,
                  name: profile.name,
                  size: 110,
                ),
                Container(
                  padding: EdgeInsets.all(AppDimens.xs.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 16.sp,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimens.xs.h),
            Text(
              AppStrings.changePhoto,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary row that opens the surah picker (screen 03). Shows ayahs rather
/// than surahs, because a part-done surah is now expressible.
class _MemorizedSurahsRow extends StatelessWidget {
  final MemorizedAyahs memorized;
  final VoidCallback onTap;

  const _MemorizedSurahsRow({required this.memorized, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusMd.r);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: AppDimens.rowHeight.h,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${memorized.totalAyahs} ${AppStrings.ayahCount} · '
                  '${memorized.startedSurahs.length} ${AppStrings.surahUnit}',
                  style: AppTextStyles.bodyStrong,
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecondary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
