import 'package:equatable/equatable.dart';
import '../../memorization/models/memorized_ayahs.dart';
import '../../onboarding/models/memorization_level.dart';

/// Everything the user can change about themselves on screen 35
/// ("تعديل الملف الشخصي") — identity in shared preferences, memorization in
/// the onboarding profile.
class EditableProfile extends Equatable {
  final String name;

  /// Absolute path to the avatar image in app storage; null while the user
  /// still has the generated initials circle.
  final String? avatarPath;

  final MemorizationLevel level;

  /// What the user counts as memorized, at ayah resolution.
  final MemorizedAyahs memorized;

  const EditableProfile({
    this.name = '',
    this.avatarPath,
    this.level = MemorizationLevel.beginner,
    this.memorized = MemorizedAyahs.empty,
  });

  EditableProfile copyWith({
    String? name,
    String? avatarPath,
    bool clearAvatar = false,
    MemorizationLevel? level,
    MemorizedAyahs? memorized,
  }) {
    return EditableProfile(
      name: name ?? this.name,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      level: level ?? this.level,
      memorized: memorized ?? this.memorized,
    );
  }

  @override
  List<Object?> get props => [name, avatarPath, level, memorized];
}
