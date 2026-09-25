import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/app_progress_bar.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../domain/memorization/models/memorized_ayahs.dart';
import '../../../domain/memorization/repositories/memorization_repository.dart';
import '../../../domain/quran/models/ayah.dart';
import '../../../domain/quran/models/surah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../../challenges/pages/surah_challenges_page.dart';

/// Reading view for one surah — the step the app was missing between
/// "choose a surah" and "be tested on it".
///
/// Ayah text is set in the bundled Uthmani face; everything else stays in the
/// UI face so the mushaf text is visually distinct from the chrome.
///
/// Tapping an ayah marks it memorized. This is the only place memorization can
/// be recorded at ayah resolution — the surah picker only does whole surahs —
/// and it writes straight through, so there is nothing to save.
class SurahReaderPage extends StatefulWidget {
  final Surah surah;

  const SurahReaderPage({super.key, required this.surah});

  @override
  State<SurahReaderPage> createState() => _SurahReaderPageState();
}

class _SurahReaderPageState extends State<SurahReaderPage> {
  late final Future<List<Ayah>> _ayahs;
  final _memorization = getIt<MemorizationRepository>();
  late MemorizedAyahs _memorized;

  /// Al-Fatihah carries the basmalah as its first ayah, and At-Tawbah has none
  /// — every other surah gets it as a heading above the text.
  bool get _showBasmalah =>
      widget.surah.number != 1 && widget.surah.number != 9;

  @override
  void initState() {
    super.initState();
    _ayahs = getIt<QuranRepository>().getAyahs(widget.surah.number);
    _memorized = _memorization.get();
  }

  int get _memorizedHere => _memorized.countIn(widget.surah.number);

  bool get _wholeSurah =>
      _memorized.isWholeSurah(widget.surah.number, widget.surah.ayahCount);

  Future<void> _toggleAyah(int ayah) async {
    final next = await _memorization.toggleAyah(widget.surah.number, ayah);
    if (mounted) setState(() => _memorized = next);
  }

  Future<void> _toggleWholeSurah() async {
    final next = await _memorization.setWholeSurah(
      widget.surah.number,
      widget.surah.ayahCount,
      memorized: !_wholeSurah,
    );
    if (mounted) setState(() => _memorized = next);
  }

  void _practice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahChallengesPage(surah: widget.surah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surah;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('سورة ${surah.name}'),
        actions: [
          IconButton(
            onPressed: _toggleWholeSurah,
            tooltip: _wholeSurah
                ? AppStrings.clearWholeSurah
                : AppStrings.markWholeSurah,
            icon: Icon(
              _wholeSurah
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              color: _wholeSurah ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: _practice,
            child: Text(
              AppStrings.practice,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Ayah>>(
          future: _ayahs,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.lg.w),
                  child: const Text(
                    AppStrings.genericError,
                    style: AppTextStyles.body,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final ayahs = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppDimens.screenH.w,
                AppDimens.sm.h,
                AppDimens.screenH.w,
                AppDimens.xl.h,
              ),
              // One extra leading item for the surah heading.
              itemCount: ayahs.length + 1,
              separatorBuilder: (_, i) =>
                  SizedBox(height: i == 0 ? AppDimens.md.h : AppDimens.sm.h),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _SurahHeading(
                    surah: surah,
                    showBasmalah: _showBasmalah,
                    memorized: _memorizedHere,
                  );
                }
                final ayah = ayahs[i - 1];
                return _AyahBlock(
                  ayah: ayah,
                  memorized: _memorized.contains(surah.number, ayah.number),
                  onTap: () => _toggleAyah(ayah.number),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Name, meta line, and the basmalah where the surah doesn't already carry it.
class _SurahHeading extends StatelessWidget {
  final Surah surah;
  final bool showBasmalah;
  final int memorized;

  const _SurahHeading({
    required this.surah,
    required this.showBasmalah,
    required this.memorized,
  });

  static const String _basmalah = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.lg.w,
            vertical: AppDimens.md.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg.r),
          ),
          child: Column(
            children: [
              Text(
                'سورة ${surah.name}',
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppDimens.xxs.h),
              Text(
                '${toArabicNumerals(surah.ayahCount)} آية · '
                '${surah.revelationType.arabicLabel}',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: AppDimens.sm.h),
              Text(
                '${toArabicNumerals(memorized)}'
                ' / ${toArabicNumerals(surah.ayahCount)}'
                ' ${AppStrings.memorizedOfTotal}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppDimens.xs.h),
              AppProgressBar(
                value: surah.ayahCount == 0 ? 0 : memorized / surah.ayahCount,
                color: AppColors.primary,
                trackColor: AppColors.mintStrong,
                height: 6,
              ),
            ],
          ),
        ),
        if (showBasmalah) ...[
          SizedBox(height: AppDimens.lg.h),
          Text(
            _basmalah,
            textAlign: TextAlign.center,
            style: AppTextStyles.ayah.copyWith(color: AppColors.primaryDarker),
          ),
        ],
      ],
    );
  }
}

/// One ayah: the text, closed by its number in an Arabic-Indic marker the way
/// a printed mushaf ends a verse.
class _AyahBlock extends StatelessWidget {
  final Ayah ayah;
  final bool memorized;
  final VoidCallback onTap;

  const _AyahBlock({
    required this.ayah,
    required this.memorized,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusMd.r);
    return Semantics(
      selected: memorized,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.md.w,
              vertical: AppDimens.md.h,
            ),
            decoration: BoxDecoration(
              color: memorized ? AppColors.mint : AppColors.surfaceElevated,
              borderRadius: radius,
              border: Border.all(
                color: memorized ? AppColors.primary : AppColors.border,
                width: memorized ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '${ayah.text} '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _AyahMarker(
                          number: ayah.number,
                          memorized: memorized,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                  style: AppTextStyles.ayah.copyWith(
                    color: AppColors.primaryDarker,
                  ),
                ),
                if (memorized) ...[
                  SizedBox(height: AppDimens.xs.h),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppDimens.xxs.w),
                      Text(
                        AppStrings.memorizedOfTotal,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AyahMarker extends StatelessWidget {
  final int number;
  final bool memorized;

  const _AyahMarker({required this.number, this.memorized = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 26.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: memorized ? AppColors.mintStrong : AppColors.mint,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        toArabicNumerals(number),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
