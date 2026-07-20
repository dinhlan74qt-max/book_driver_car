import 'package:book_drive_car/core/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:book_drive_car/core/features/welcome/presentation/view/welcome_screen.dart';
import 'package:book_drive_car/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarNow',
      theme: AppTheme.light(),
      home: OnboardingScreen(),
    );
  }
}
