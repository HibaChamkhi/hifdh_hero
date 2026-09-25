import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'data/memorization/repositories/memorization_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Upgrades profiles written before memorization was tracked per ayah.
  // No-op once done, so it stays on the launch path safely.
  await getIt<MemorizationMigration>().run();
  runApp(
    ScreenUtilInit(
      designSize: const Size(
        428,
        810,
      ), // iPhone-ish design canvas (from starter)
      minTextAdapt: true,
      builder: (context, child) => const HifzHeroApp(),
    ),
  );
}
