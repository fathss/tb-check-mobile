import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/admin_faskes/dashboard/screens/admin_dashboard_screen.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';
import 'features/admin_faskes/navigation/admin_main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCare Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "PlusJakartaSans",
        colorScheme: .fromSeed(seedColor: AppColors.primary),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}