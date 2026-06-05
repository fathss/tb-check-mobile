import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart'; 

import '../pages/schedule_page.dart';
import '../widgets/medicine_schedule_card.dart';
import '../widgets/medicine_item_card.dart';
import '../pages/medicine_detail_page.dart';
import '../pages/medicine_list_page.dart';

class MedicinePage extends ConsumerStatefulWidget {
  const MedicinePage({super.key});

  @override
  ConsumerState<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends ConsumerState<MedicinePage> {
  String? _currentUserId;
  String? _patientId; 
  bool _hasFetched = false; // Penanda agar API tidak dipanggil berulang-ulang

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // --- AMBIL USER ID SECARA ASYNC SEPERTI DI HOME PAGE ---
  Future<void> _loadUserId() async {
    final storage = ref.read(authStorageProvider);
    final id = await storage.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika User ID belum didapatkan
    if (_currentUserId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Pantau data Profil Summary menggunakan ID yang valid
    final summaryAsync = ref.watch(homeSummaryProvider(_currentUserId!));

    final medicineProvider = context.watch<MedicineProvider>();
    final todaySchedules = medicineProvider.todaySchedules;
    final allMedicines = medicineProvider.allMedicines;
    final recentMedicines = allMedicines.take(2).toList(); 

    // --- CARA AMAN MEMANGGIL API TANPA LOOPING ---
    summaryAsync.whenData((summary) {
      if (summary.patientId != null) {
        // Simpan patient ID untuk dipakai oleh widget anak (Schedule Card)
        if (_patientId != summary.patientId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _patientId = summary.patientId);
          });
        }

        // Panggil API HANYA jika datanya belum pernah di-fetch di sesi ini
        if (!_hasFetched && !medicineProvider.isLoading) {
          _hasFetched = true; // Kunci agar tidak looping
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MedicineProvider>().fetchTodaySchedule(summary.patientId!);
            context.read<MedicineProvider>().fetchAllMedicines(summary.patientId!);
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Manajemen Obat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),

                /// JADWAL HARI INI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jadwal Hari Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SchedulePage()));
                      },
                      child: const Text("Lihat Kalender", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (medicineProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (todaySchedules.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text("Belum ada jadwal obat hari ini.", style: TextStyle(color: Colors.grey.shade500))))
                else
                  ...todaySchedules.map((schedule) {
                    return MedicineScheduleCard(
                      scheduleId: schedule.scheduleId,
                      patientId: _patientId ?? "", // ID dinamis
                      time: schedule.time,
                      medicineName: schedule.title,
                      description: schedule.subtitle,
                      initialDone: schedule.isDone,
                    );
                  }),

                const SizedBox(height: 40),

                /// DAFTAR OBAT ANDA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Daftar Obat Anda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineListPage()));
                      },
                      child: const Text("Lihat Semua", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (medicineProvider.isLoading && recentMedicines.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (recentMedicines.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text("Belum ada obat yang ditambahkan", style: TextStyle(color: Colors.grey.shade500))))
                else
                  ...recentMedicines.map((med) {
                    List<dynamic> times = [];
                    if (med['schedulesJson'] != null) {
                      try { times = jsonDecode(med['schedulesJson']); } catch (_) {}
                    }
                    List<dynamic> activeDaysDyn = [];
                    if (med['activeDaysJson'] != null) {
                      try { activeDaysDyn = jsonDecode(med['activeDaysJson']); } catch (_) {}
                    }
                    List<bool> activeDays = activeDaysDyn.map((e) => e == true).toList();

                    String scheduleText = times.isNotEmpty ? times.join(', ') : 'Belum diatur';
                    scheduleText += " - ${med['consumeCondition'] ?? ''}";

                    return MedicineItemCard(
                      title: "${med['name']}, ${med['dosage']}",
                      subtitle: "Sisa Stok: ${med['stock']}",
                      schedule: scheduleText,
                      imageIndex: med['selectedImageIndex'] ?? 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineDetailPage(
                              medicineName: med['name'] ?? '',
                              function: med['function'] ?? '',
                              consumeTimes: times.map((e) => e.toString()).toList(),
                              dose: med['dosage'] ?? '',
                              stock: med['stock']?.toString() ?? '0',
                              condition: med['consumeCondition'] ?? '',
                              activeDays: activeDays,
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}