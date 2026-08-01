import 'package:book_drive_car/features/splash/presentation/view/splash_screen.dart';
import 'package:book_drive_car/shared/constants/app_keys.dart';
import 'package:book_drive_car/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'CarNow',
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
