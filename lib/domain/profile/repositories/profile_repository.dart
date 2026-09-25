import '../models/editable_profile.dart';

/// Read/write access to the parts of the profile the user owns (screen 35).
abstract class ProfileRepository {
  EditableProfile getProfile();

  Future<void> save(EditableProfile profile);

  /// Copies the picked image into app storage and returns its durable path.
  /// The picker hands back a cache path that the OS may reclaim, so the file
  /// has to be taken out of the cache before it is stored on the profile.
  Future<String> persistAvatar(String pickedPath);
}
