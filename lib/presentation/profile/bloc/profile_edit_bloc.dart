import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/error_utils.dart';
import '../../../core/model/ui_state.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/onboarding/models/memorization_level.dart';
import '../../../domain/profile/models/editable_profile.dart';
import '../../../domain/profile/repositories/profile_repository.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

/// Screen 35 — edits are held in a working copy and only written on
/// [ProfileEditSubmitted], so backing out of the screen discards them.
@injectable
class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final ProfileRepository repository;

  ProfileEditBloc(this.repository) : super(const ProfileEditState()) {
    on<ProfileEditRequested>(_onRequested);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileAvatarPicked>(_onAvatarPicked);
    on<ProfileAvatarRemoved>(_onAvatarRemoved);
    on<ProfileLevelChanged>(_onLevelChanged);
    on<ProfileSurahsChanged>(_onSurahsChanged);
    on<ProfileEditSubmitted>(_onSubmitted);
  }

  void _onRequested(
    ProfileEditRequested event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      emit(
        state.copyWith(
          status: UIStatus.success,
          profile: repository.getProfile(),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }

  void _onNameChanged(
    ProfileNameChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(
      state.copyWith(
        profile: state.profile.copyWith(name: event.name),
        saved: false,
      ),
    );
  }

  Future<void> _onAvatarPicked(
    ProfileAvatarPicked event,
    Emitter<ProfileEditState> emit,
  ) async {
    try {
      final path = await repository.persistAvatar(event.pickedPath);
      emit(
        state.copyWith(
          profile: state.profile.copyWith(avatarPath: path),
          saved: false,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }

  void _onAvatarRemoved(
    ProfileAvatarRemoved event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(
      state.copyWith(
        profile: state.profile.copyWith(clearAvatar: true),
        saved: false,
      ),
    );
  }

  void _onLevelChanged(
    ProfileLevelChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(
      state.copyWith(
        profile: state.profile.copyWith(level: event.level),
        saved: false,
      ),
    );
  }

  void _onSurahsChanged(
    ProfileSurahsChanged event,
    Emitter<ProfileEditState> emit,
  ) {
    emit(
      state.copyWith(
        profile: state.profile.copyWith(memorized: event.memorized),
        saved: false,
      ),
    );
  }

  Future<void> _onSubmitted(
    ProfileEditSubmitted event,
    Emitter<ProfileEditState> emit,
  ) async {
    emit(state.copyWith(status: UIStatus.loading));
    try {
      await repository.save(state.profile);
      emit(state.copyWith(status: UIStatus.success, saved: true));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: UIStatus.error,
          message: mapExceptionToMessage(e),
        ),
      );
    }
  }
}
