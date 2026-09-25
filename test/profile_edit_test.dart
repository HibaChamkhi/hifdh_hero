import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/model/ui_state.dart';
import 'package:hifdh_hero/domain/onboarding/models/memorization_level.dart';
import 'package:hifdh_hero/domain/memorization/models/ayah_range.dart';
import 'package:hifdh_hero/domain/memorization/models/memorized_ayahs.dart';
import 'package:hifdh_hero/domain/profile/models/editable_profile.dart';
import 'package:hifdh_hero/domain/profile/repositories/profile_repository.dart';
import 'package:hifdh_hero/presentation/profile/bloc/profile_edit_bloc.dart';

class _FakeProfileRepository implements ProfileRepository {
  EditableProfile stored;
  EditableProfile? saved;
  int persistCalls = 0;
  bool failPersist = false;

  _FakeProfileRepository(this.stored);

  @override
  EditableProfile getProfile() => stored;

  @override
  Future<void> save(EditableProfile profile) async {
    saved = profile;
    stored = profile;
  }

  @override
  Future<String> persistAvatar(String pickedPath) async {
    persistCalls++;
    if (failPersist) throw Exception('copy failed');
    return '/documents/avatar_1.jpg';
  }
}

void main() {
  late _FakeProfileRepository repository;

  ProfileEditBloc build() => ProfileEditBloc(repository);

  setUp(() {
    repository = _FakeProfileRepository(
      EditableProfile(
        name: 'سارة يوسف',
        level: MemorizationLevel.beginner,
        memorized: MemorizedAyahs.of(const [
          AyahRange(surah: 1, start: 1, end: 7),
        ]),
      ),
    );
  });

  test('loads the stored profile', () async {
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    expect(bloc.state.profile.name, 'سارة يوسف');
    expect(bloc.state.profile.memorized.startedSurahs, {1});
    await bloc.close();
  });

  test('edits stay in the working copy until submitted', () async {
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    bloc
      ..add(const ProfileNameChanged('هبة'))
      ..add(const ProfileLevelChanged(MemorizationLevel.hafiz))
      ..add(
        ProfileSurahsChanged(
          MemorizedAyahs.wholeSurahs(const [1, 112], const {1: 7, 112: 4}),
        ),
      );
    await bloc.stream.firstWhere((s) => s.profile.memorized.contains(112, 1));

    // Nothing written yet — backing out of the screen must discard.
    expect(repository.saved, isNull);

    bloc.add(const ProfileEditSubmitted());
    await bloc.stream.firstWhere((s) => s.saved);

    expect(repository.saved!.name, 'هبة');
    expect(repository.saved!.level, MemorizationLevel.hafiz);
    expect(repository.saved!.memorized.startedSurahs, {1, 112});
    await bloc.close();
  });

  test('the picker result replaces the whole memorized set', () async {
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    // Surah 1 was memorized; the picker came back without it and with 112.
    bloc.add(
      ProfileSurahsChanged(
        MemorizedAyahs.wholeSurahs(const [112], const {112: 4}),
      ),
    );
    await bloc.stream.firstWhere((s) => !s.profile.memorized.contains(1, 1));

    expect(bloc.state.profile.memorized.startedSurahs, {112});
    await bloc.close();
  });

  test('a partly-memorized surah survives the picker untouched', () async {
    // 20 ayahs of Al-Baqarah, marked while reading.
    repository.stored = EditableProfile(
      name: 'سارة',
      memorized: MemorizedAyahs.of(const [
        AyahRange(surah: 2, start: 1, end: 20),
      ]),
    );
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    // The picker returns the same partial range plus a whole new surah.
    bloc.add(
      ProfileSurahsChanged(
        MemorizedAyahs.of(const [
          AyahRange(surah: 2, start: 1, end: 20),
          AyahRange(surah: 112, start: 1, end: 4),
        ]),
      ),
    );
    await bloc.stream.firstWhere((s) => s.profile.memorized.contains(112, 1));

    expect(bloc.state.profile.memorized.countIn(2), 20);
    expect(bloc.state.profile.memorized.isWholeSurah(2, 286), isFalse);
    await bloc.close();
  });

  test('a picked photo is copied out of the picker cache', () async {
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    bloc.add(const ProfileAvatarPicked('/cache/tmp123.jpg'));
    await bloc.stream.firstWhere((s) => s.profile.avatarPath != null);

    expect(repository.persistCalls, 1);
    // The durable path is stored, never the cache path.
    expect(bloc.state.profile.avatarPath, '/documents/avatar_1.jpg');
    await bloc.close();
  });

  test('removing the photo clears the path', () async {
    repository.stored = const EditableProfile(
      name: 'سارة',
      avatarPath: '/documents/avatar_1.jpg',
    );
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    bloc.add(const ProfileAvatarRemoved());
    await bloc.stream.firstWhere((s) => s.profile.avatarPath == null);

    bloc.add(const ProfileEditSubmitted());
    await bloc.stream.firstWhere((s) => s.saved);

    expect(repository.saved!.avatarPath, isNull);
    await bloc.close();
  });

  test(
    'a failed photo copy surfaces an error, leaving the avatar alone',
    () async {
      repository.failPersist = true;
      final bloc = build()..add(const ProfileEditRequested());
      await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

      bloc.add(const ProfileAvatarPicked('/cache/tmp123.jpg'));
      await bloc.stream.firstWhere((s) => s.status == UIStatus.error);

      expect(bloc.state.profile.avatarPath, isNull);
      await bloc.close();
    },
  );

  test('an empty name blocks saving', () async {
    final bloc = build()..add(const ProfileEditRequested());
    await bloc.stream.firstWhere((s) => s.status == UIStatus.success);

    expect(bloc.state.canSave, isTrue);
    bloc.add(const ProfileNameChanged('   '));
    await bloc.stream.firstWhere((s) => !s.canSave);
    await bloc.close();
  });
}
