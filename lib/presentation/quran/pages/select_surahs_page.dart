import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/ui/widgets/app_search_field.dart';
import '../../../core/ui/widgets/empty_state.dart';
import '../../../core/ui/widgets/selection_row.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/quran/models/surah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';

/// Screen 03 — "السور التي حفظتها".
///
/// Deliberately owns no bloc: onboarding and profile-editing both need this
/// list but keep their selection in different places, so the page holds a
/// working copy and hands it back on تم. Backing out discards.
///
/// Toggling a row marks or clears the whole surah. A surah that is only
/// partly memorized — say the first 20 ayahs of Al-Baqarah, marked while
/// reading — shows its count and is left alone unless the user taps it.
///
/// Returns the edited set, or null if the user backed out.
Future<MemorizedAyahs?> showSelectSurahs(
  BuildContext context,
  MemorizedAyahs initial,
) {
  return Navigator.of(context).push<MemorizedAyahs>(
    MaterialPageRoute(builder: (_) => SelectSurahsPage(initial: initial)),
  );
}

class SelectSurahsPage extends StatefulWidget {
  final MemorizedAyahs initial;

  const SelectSurahsPage({super.key, required this.initial});

  @override
  State<SelectSurahsPage> createState() => _SelectSurahsPageState();
}

class _SelectSurahsPageState extends State<SelectSurahsPage> {
  late final Future<List<Surah>> _surahs;
  late MemorizedAyahs _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _surahs = getIt<QuranRepository>().getSurahs();
  }

  /// Marking a whole surah replaces whatever was marked ayah by ayah in the
  /// reader, so a part-done surah asks first — that detail is hand-entered and
  /// there is no undo.
  Future<void> _toggleSurah(Surah surah) async {
    final done = _selected.countIn(surah.number);
    final whole = _selected.isWholeSurah(surah.number, surah.ayahCount);
    final partial = done > 0 && !whole;

    if (partial && !await _confirmOverwrite()) return;

    setState(() {
      _selected = _selected.setWholeSurah(
        surah.number,
        surah.ayahCount,
        !whole,
      );
    });
  }

  Future<bool> _confirmOverwrite() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(AppStrings.overwritePartialTitle),
        content: const Text(AppStrings.overwritePartialBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.confirm,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Matches the Arabic name, the transliteration, or the surah number.
  List<Surah> _visible(List<Surah> all) {
    final q = _query.trim();
    if (q.isEmpty) return all;
    final lower = q.toLowerCase();
    return all
        .where(
          (s) =>
              s.name.contains(q) ||
              s.englishName.toLowerCase().contains(lower) ||
              s.number.toString() == q,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(AppStrings.memorizedSurahs),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(
              AppStrings.done,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenH.w,
                vertical: AppDimens.sm.h,
              ),
              child: AppSearchField(
                hint: AppStrings.searchSurah,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Surah>>(
                future: _surahs,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final surahs = _visible(snapshot.data!);
                  if (surahs.isEmpty) {
                    return const EmptyState(title: AppStrings.noSurahFound);
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppDimens.screenH.w,
                      0,
                      AppDimens.screenH.w,
                      AppDimens.lg.h,
                    ),
                    itemCount: surahs.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppDimens.xs.h),
                    itemBuilder: (context, i) {
                      final surah = surahs[i];
                      final done = _selected.countIn(surah.number);
                      final whole = _selected.isWholeSurah(
                        surah.number,
                        surah.ayahCount,
                      );
                      final partial = done > 0 && !whole;
                      return SelectionRow(
                        label: partial
                            ? '${surah.name}  '
                                  '(${toArabicNumerals(done)}'
                                  '/${toArabicNumerals(surah.ayahCount)})'
                            : surah.name,
                        selected: whole,
                        // Solid mint is the screen-03 treatment.
                        solid: true,
                        onTap: () => _toggleSurah(surah),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
