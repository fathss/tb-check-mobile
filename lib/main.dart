import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- TAMBAHKAN IMPORT WORKMANAGER DAN SERVICE ---
import 'package:workmanager/workmanager.dart';
import 'package:tbcheck_app/core/services/background_location_service.dart';
// ------------------------------------------------

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/utils/jwt_utils.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';
import 'package:tbcheck_app/core/navigation/main_page.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';
import 'package:tbcheck_app/features/admin_faskes/navigation/admin_main_navigation.dart';
import 'package:tbcheck_app/features/super_admin/presentation/navigation/super_admin_main_page.dart';

import 'package:tbcheck_app/features/admin_faskes/patients/providers/patient_provider.dart';
import 'package:tbcheck_app/features/admin_faskes/dashboard/providers/dashboard_provider.dart';
import 'package:tbcheck_app/features/admin_faskes/profile/providers/faskes_profile_provider.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';

// --- IMPORT NOTIFICATION PROVIDER BARU ---
import 'package:tbcheck_app/features/notifications/providers/notification_provider.dart'; // Sesuaikan path jika berbeda

Future<void> main() async {
  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  // ========================================================
  // 2. INISIALISASI & DAFTARKAN BACKGROUND SERVICE (LOKASI)
  // ========================================================
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Beri notif saat jalan (Ubah ke false saat rilis)
  );

  Workmanager().registerPeriodicTask(
    "1", // ID Unik Tugas
    fetchBackgroundLocationTask,
    frequency: const Duration(minutes: 15), // Berjalan 1 Jam Sekali
    constraints: Constraints(
      networkType: NetworkType.connected, // Hanya jalan jika ada internet
    ),
  );
  // ========================================================

  // 3. Setup Localization
  await initializeDateFormatting('id_ID', null);

  runApp(
    // Riverpod harus berada di lapisan paling luar
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PatientProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => FaskesProfileProvider()),
          ChangeNotifierProvider(create: (_) => MedicineProvider()),
          // --- DAFTARKAN NOTIFICATION PROVIDER DI SINI ---
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "PlusJakartaSans",
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      routes: {'/login': (context) => const LandingPage()},
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  late final Future<_AuthDestination> _authDestinationFuture;

  @override
  void initState() {
    super.initState();
    _authDestinationFuture = _resolveDestination();
  }

  Future<_AuthDestination> _resolveDestination() async {
    final storage = ref.read(authStorageProvider);
    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      await storage.clearSession();
      return _AuthDestination.login;
    }

    if (!JwtUtils.isUsable(token)) {
      await storage.clearSession();
      return _AuthDestination.login;
    }

    final normalizedRole = _normalizeRole(JwtUtils.role(token));
    switch (normalizedRole) {
      case 'patient':
        return _AuthDestination.patient;
      case 'admin':
        return _AuthDestination.admin;
      case 'super admin':
        return _AuthDestination.superAdmin;
      default:
        await storage.clearSession();
        return _AuthDestination.login;
    }
  }

  String _normalizeRole(String? role) {
    return role?.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
  }

  Widget _buildDestination(_AuthDestination destination) {
    switch (destination) {
      case _AuthDestination.patient:
        return const MainPage();
      case _AuthDestination.admin:
        return const AdminMainNavigation();
      case _AuthDestination.superAdmin:
        return const SuperAdminMainPage();
      case _AuthDestination.login:
        return const LandingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthDestination>(
      future: _authDestinationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final destination = snapshot.data ?? _AuthDestination.login;
        return _buildDestination(destination);
      },
    );
  }
}

enum _AuthDestination { login, patient, admin, superAdmin }