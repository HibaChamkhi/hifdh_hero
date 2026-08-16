import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/revision/models/ayah_review_state.dart';

/// Persists spaced-repetition state + the review-day log in SharedPreferences.
abstract class RevisionLocalDataSource {
  List<AyahReviewState> getStates();
  Future<void> saveStates(List<AyahReviewState> states);
  Set<int> getReviewDays();
  Future<void> addReviewDay(int dayNumber);
}

@LazySingleton(as: RevisionLocalDataSource)
class RevisionLocalDataSourceImpl implements RevisionLocalDataSource {
  final SharedPreferences sharedPreferences;
  RevisionLocalDataSourceImpl({required this.sharedPreferences});

  static const _kStates = 'revision_states';
  static const _kDays = 'revision_days';

  @override
  List<AyahReviewState> getStates() {
    final raw = sharedPreferences.getString(_kStates);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List;
    return list
        .map((e) => AyahReviewState.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveStates(List<AyahReviewState> states) async {
    final raw = json.encode(states.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_kStates, raw);
  }

  @override
  Set<int> getReviewDays() {
    final list = sharedPreferences.getStringList(_kDays) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  @override
  Future<void> addReviewDay(int dayNumber) async {
    final days = getReviewDays()..add(dayNumber);
    await sharedPreferences.setStringList(
      _kDays,
      days.map((e) => e.toString()).toList(),
    );
  }
}
