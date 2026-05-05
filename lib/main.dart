import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCheck',
      theme: ThemeData(
        fontFamily: "PlusJakartaSans",
        colorScheme: .fromSeed(seedColor: AppColors.primary),
      ),
      home: const LandingPage(),
    );
  }
}
