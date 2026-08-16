import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/domain/revision/models/ayah_review_state.dart';
import 'package:hifdh_hero/domain/revision/services/spaced_repetition.dart';

void main() {
  const sr = SpacedRepetition();
  const today = 1000;

  test('initial state is due immediately (box 0)', () {
    final s = sr.initial(surahNumber: 1, ayahNumber: 1, today: today);
    expect(s.box, 0);
    expect(s.dueDay, today); // intervals[0] == 0
    expect(s.isDue(today), isTrue);
    expect(s.isWeak(today), isTrue);
  });

  test('correct review promotes the box and pushes the due date out', () {
    final s0 = sr.initial(surahNumber: 1, ayahNumber: 1, today: today);
    final s1 = sr.review(s0, true, today);
    expect(s1.box, 1);
    expect(s1.dueDay, today + SpacedRepetition.intervals[1]); // +1
    expect(s1.reviewCount, 1);
    expect(s1.lapses, 0);
    expect(s1.lastReviewedDay, today);
  });

  test('several correct reviews reach a strong, far-future state', () {
    var s = sr.initial(surahNumber: 1, ayahNumber: 1, today: today);
    var day = today;
    for (var i = 0; i < 5; i++) {
      s = sr.review(s, true, day);
      day = s.dueDay;
    }
    expect(s.box, AyahReviewState.maxBox);
    expect(s.strengthPercent, 100);
    expect(s.isWeak(s.dueDay), isFalse);
  });

  test('incorrect review demotes the box and counts a lapse', () {
    var s = sr.initial(surahNumber: 1, ayahNumber: 1, today: today, box: 3);
    final before = s.box;
    s = sr.review(s, false, today);
    expect(s.box, before - 1);
    expect(s.lapses, 1);
    expect(s.isWeak(today), isTrue);
  });

  test('box never exceeds max or drops below zero', () {
    var s = sr.initial(surahNumber: 1, ayahNumber: 1, today: today, box: 5);
    s = sr.review(s, true, today);
    expect(s.box, 5);
    s = sr.initial(surahNumber: 1, ayahNumber: 1, today: today, box: 0);
    s = sr.review(s, false, today);
    expect(s.box, 0);
  });
}
