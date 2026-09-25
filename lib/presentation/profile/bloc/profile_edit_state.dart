part of 'profile_edit_bloc.dart';

class ProfileEditState extends Equatable {
  final UIStatus status;
  final String message;

  /// The working copy — only written to storage on submit.
  final EditableProfile profile;

  /// True for the one state emitted after a successful save, so the view can
  /// pop exactly once.
  final bool saved;

  const ProfileEditState({
    this.status = UIStatus.initial,
    this.message = '',
    this.profile = const EditableProfile(),
    this.saved = false,
  });

  bool get canSave => profile.name.trim().isNotEmpty;

  ProfileEditState copyWith({
    UIStatus? status,
    String? message,
    EditableProfile? profile,
    bool? saved,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      message: message ?? this.message,
      profile: profile ?? this.profile,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [status, message, profile, saved];
}
