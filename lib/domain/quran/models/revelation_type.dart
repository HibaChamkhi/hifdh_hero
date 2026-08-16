/// Where a surah was revealed.
enum RevelationType {
  meccan,
  medinan;

  static RevelationType fromKey(String? key) =>
      key == 'medinan' ? RevelationType.medinan : RevelationType.meccan;

  bool get isMeccan => this == RevelationType.meccan;

  /// Arabic label used in the UI (e.g. "مكية"/"مدنية").
  String get arabicLabel => isMeccan ? 'مكية' : 'مدنية';
}
