import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(
    ScreenUtilInit(
      designSize: const Size(428, 810), // iPhone-ish design canvas (from starter)
      minTextAdapt: true,
      builder: (context, child) => const HifzHeroApp(),
    ),
  );
}
