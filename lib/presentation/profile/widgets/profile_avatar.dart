import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/utils/initials.dart';

/// The round profile mark: the user's photo when they have set one, otherwise
/// the green circle with their initials (screens 11 and 35).
class ProfileAvatar extends StatelessWidget {
  /// Absolute path in app storage. A stale path — the file deleted from under
  /// us — falls back to initials rather than showing a broken image.
  final String? imagePath;

  final String name;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    final File? file = _existingFile;
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: file != null
          ? Image.file(
              file,
              width: size.w,
              height: size.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initials(name: name, size: size),
            )
          : _Initials(name: name, size: size),
    );
  }

  File? get _existingFile {
    final path = imagePath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;

  const _Initials({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final letters = initialsOf(name);
    return Text(
      // No name captured yet — the app's own wordmark stands in.
      letters.isEmpty ? 'حفظ' : letters,
      textAlign: TextAlign.center,
      style: AppTextStyles.h1.copyWith(
        color: AppColors.onPrimary,
        fontSize: (size * 0.26).sp,
      ),
    );
  }
}
