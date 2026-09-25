import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hifdh_hero/core/ui/styles/text_styles.dart';

/// The app used to name font families it never bundled, so ayah text silently
/// rendered in the platform font. These guard against that regressing.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('every family the type system names is registered in pubspec', () {
    for (final family in [
      AppTextStyles.uiFont,
      AppTextStyles.latinFont,
      AppTextStyles.quranFont,
    ]) {
      expect(
        pubspec,
        contains('family: $family'),
        reason: '$family is used in text_styles.dart but never bundled',
      );
    }
  });

  test('every asset pubspec points at exists and is a real font', () {
    final assets = RegExp(
      r'- asset: (assets/fonts/\S+)',
    ).allMatches(pubspec).map((m) => m.group(1)!).toList();

    expect(assets, isNotEmpty);
    for (final path in assets) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path is missing');
      // TrueType files start with the 0x00010000 sxxversion tag; an HTML error
      // page saved by a failed download would not.
      final header = file.readAsBytesSync().take(4).toList();
      expect(
        header,
        anyOf(equals([0, 1, 0, 0]), equals(utf8.encode('OTTO'))),
        reason: '$path is not a TrueType/OpenType file',
      );
    }
  });

  test('the Quran face is distinct from the UI face', () {
    // Ayah text needs Uthmani letterforms; reusing the UI face would lose them.
    expect(AppTextStyles.quranFont, isNot(AppTextStyles.uiFont));
    expect(AppTextStyles.ayah.fontFamily, AppTextStyles.quranFont);
  });
}
