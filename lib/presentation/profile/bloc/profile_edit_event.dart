part of 'profile_edit_bloc.dart';

abstract class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object?> get props => [];
}

class ProfileEditRequested extends ProfileEditEvent {
  const ProfileEditRequested();
}

class ProfileNameChanged extends ProfileEditEvent {
  final String name;
  const ProfileNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

/// [pickedPath] is the picker's cache path; the repository copies it into app
/// storage before it lands on the profile.
class ProfileAvatarPicked extends ProfileEditEvent {
  final String pickedPath;
  const ProfileAvatarPicked(this.pickedPath);

  @override
  List<Object?> get props => [pickedPath];
}

class ProfileAvatarRemoved extends ProfileEditEvent {
  const ProfileAvatarRemoved();
}

class ProfileLevelChanged extends ProfileEditEvent {
  final MemorizationLevel level;
  const ProfileLevelChanged(this.level);

  @override
  List<Object?> get props => [level];
}

/// The full memorized set, as returned by the surah picker.
class ProfileSurahsChanged extends ProfileEditEvent {
  final MemorizedAyahs memorized;
  const ProfileSurahsChanged(this.memorized);

  @override
  List<Object?> get props => [memorized];
}

class ProfileEditSubmitted extends ProfileEditEvent {
  const ProfileEditSubmitted();
}
