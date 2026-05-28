import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// --- Theme & Core ---
import 'package:tbcheck_app/core/theme/app_colors.dart';
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

  // 3. Menjalankan App dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        // DAFTARKAN PROVIDER BARU:
        ChangeNotifierProvider(create: (_) => FaskesProfileProvider()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const MainPage(),
    );
  }
}
