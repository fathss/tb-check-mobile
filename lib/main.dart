import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Theme & Core ---
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/admin_faskes/dashboard/pages/admin_dashboard_screen.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/pages/user_location_history_page.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/navigation/super_admin_main_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_form_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_management_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/super_admin_dashboard.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/super_admin_profile_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/user_admin_management/admin_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/user_admin_management/user_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/user_admin_management/user_management_page.dart';
import 'package:tbcheck_app/features/user_profile/pages/complete_profile_page.dart';
import 'features/admin_faskes/navigation/admin_main_navigation.dart';
import 'package:tbcheck_app/core/navigation/main_page.dart';

// --- Features ---
import 'package:tbcheck_app/features/admin_faskes/patients/providers/patient_provider.dart';
import 'package:tbcheck_app/features/admin_faskes/dashboard/providers/dashboard_provider.dart';
import 'package:tbcheck_app/features/admin_faskes/navigation/admin_main_navigation.dart';
// IMPORT PROVIDER BARU:
import 'package:tbcheck_app/features/admin_faskes/profile/providers/faskes_profile_provider.dart';

Future<void> main() async {
  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  // 2. Setup Localization
  await initializeDateFormatting('id_ID', null);

  runApp(
    // Riverpod harus berada di lapisan paling luar
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PatientProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => FaskesProfileProvider()),
        ],
        child: MyApp(),
      ),
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const SuperAdminMainPage(),
    );
  }
}
