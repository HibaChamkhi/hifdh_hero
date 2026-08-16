import 'package:equatable/equatable.dart';

/// Outcome of a completed challenge (screen 24).
class ChallengeResult extends Equatable {
  final int total;
  final int correct;
  final int xp;
  final Duration duration;

  const ChallengeResult({
    required this.total,
    required this.correct,
    required this.xp,
    required this.duration,
  });

  /// 0.0 – 1.0
  double get accuracy => total == 0 ? 0 : correct / total;

  int get accuracyPercent => (accuracy * 100).round();

  /// mm:ss
  String get durationLabel {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [total, correct, xp, duration];
}
