import 'package:equatable/equatable.dart';
import 'revision_item.dart';

/// Today's recommended review (screen 28 — "توصية اليوم" / smart review).
class RevisionPlan extends Equatable {
  final List<RevisionItem> items;

  const RevisionPlan({this.items = const []});

  int get ayahCount => items.length;

  /// Rough estimate: ~3 minutes per ayah (matches the mockup: 3 آيات ≈ 9 دقائق).
  int get estimatedMinutes => items.length * 3;

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}
