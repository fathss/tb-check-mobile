import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/admin_faskes/dashboard/pages/admin_dashboard_screen.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/pages/user_location_history_page.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';
import 'package:tbcheck_app/features/super_admin/navigation/super_admin_main_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/faskes_management/faskes_form_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/faskes_management/faskes_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/faskes_management/faskes_management_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/super_admin_dashboard.dart';
import 'package:tbcheck_app/features/super_admin/pages/super_admin_profile_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/user_admin_management/admin_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/user_admin_management/user_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/pages/user_admin_management/user_management_page.dart';
import 'package:tbcheck_app/features/user_profile/pages/complete_profile_page.dart';
import 'features/admin_faskes/navigation/admin_main_navigation.dart';
import 'package:tbcheck_app/core/navigation/main_page.dart';
import 'package:tbcheck_app/features/home/home_page.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';
import 'package:tbcheck_app/features/home/home_page.dart';
import 'package:tbcheck_app/features/admin_faskes/patients/providers/patient_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      home: const AdminMainNavigation(),
    );
  }
}

// LandingPage (landing page + splash screen + auth page)
// CompleteProfilePage (form isi profil)
// MainPage (home page Pasien)
// AdminDashboardScreen (home page admin)
// SuperAdminMainPage (home page super admin)
