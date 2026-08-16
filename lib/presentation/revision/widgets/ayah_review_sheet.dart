import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/injection.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../domain/quran/models/ayah.dart';
import '../../../domain/quran/repositories/quran_repository.dart';
import '../../../domain/revision/models/revision_item.dart';

/// Self-graded review: shows the ayah text, then the user marks whether they
/// recalled it. Returns `true`/`false` (correct/lapsed) or `null` if dismissed.
Future<bool?> showAyahReviewSheet(BuildContext context, RevisionItem item) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl.r)),
    ),
    builder: (_) => _ReviewSheet(item: item),
  );
}

class _ReviewSheet extends StatelessWidget {
  final RevisionItem item;
  const _ReviewSheet({required this.item});

  Future<Ayah?> _loadAyah() async {
    final surah = await getIt<QuranRepository>().getSurah(item.surahNumber);
    for (final a in surah.ayahs) {
      if (a.number == item.ayahNumber) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppDimens.lg.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${item.surahName} · آية ${item.ayahNumber}',
              textAlign: TextAlign.right, style: AppTextStyles.caption),
          SizedBox(height: AppDimens.md.h),
          FutureBuilder<Ayah?>(
            future: _loadAyah(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return SizedBox(
                  height: 80.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.md.w, vertical: AppDimens.lg.h),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg.r),
                ),
                child: Text(snap.data!.text,
                    textAlign: TextAlign.right, style: AppTextStyles.ayah),
              );
            },
          ),
          SizedBox(height: AppDimens.lg.h),
          Text('هل تذكّرتِها؟',
              textAlign: TextAlign.right, style: AppTextStyles.bodyStrong),
          SizedBox(height: AppDimens.sm.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(52.h),
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: Text('لم أتقنها',
                      style: AppTextStyles.bodyStrong
                          .copyWith(color: AppColors.danger)),
                ),
              ),
              SizedBox(width: AppDimens.sm.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(52.h),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('أتقنتها', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.sm.h),
        ],
      ),
    );
  }
}
