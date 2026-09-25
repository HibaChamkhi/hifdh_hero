import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the chosen avatar out of the OS picker's cache, which can be cleared
/// at any time, by copying it into the app's documents directory.
abstract class AvatarStorage {
  Future<String> store(String pickedPath);
}

@Injectable(as: AvatarStorage)
class AvatarStorageImpl implements AvatarStorage {
  /// Timestamped so a replaced avatar gets a new path — `Image.file` caches by
  /// path, and reusing one would keep showing the previous picture.
  static const String _prefix = 'avatar_';

  @override
  Future<String> store(String pickedPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final extension = pickedPath.contains('.')
        ? pickedPath.substring(pickedPath.lastIndexOf('.'))
        : '.jpg';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final target = File('${dir.path}/$_prefix$stamp$extension');
    await File(pickedPath).copy(target.path);
    await _removeOlderThan(dir, target.path);
    return target.path;
  }

  /// One avatar is all we keep; earlier copies would otherwise pile up in the
  /// documents directory every time the user changes their picture.
  Future<void> _removeOlderThan(Directory dir, String keepPath) async {
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (name.startsWith(_prefix) && entity.path != keepPath) {
        await entity.delete();
      }
    }
  }
}
