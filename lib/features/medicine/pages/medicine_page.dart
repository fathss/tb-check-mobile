import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';
// Sesuaikan import auth_storage ini dengan struktur foldermu
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
  String? _patientId; // Simpan secara dinamis di sini

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 1. Ambil User ID yang sedang login dari storage
    final storage = ref.read(authStorageProvider);
    final userId = await storage.getUserId();
    
    if (userId != null) {
      try {
        // 2. Ambil profil summary untuk mendapatkan Patient ID
        final summary = await ref.read(homeSummaryProvider(userId).future);
        
        setState(() {
          _patientId = summary.patientId;
        });

        // 3. Panggil API Obat menggunakan Patient ID asli
        if (_patientId != null) {
          if (!mounted) return;
          context.read<MedicineProvider>().fetchTodaySchedule(_patientId!);
          context.read<MedicineProvider>().fetchAllMedicines(_patientId!); 
        }
      } catch (e) {
        print("EXCEPTION LOAD DATA: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicineProvider = context.watch<MedicineProvider>();
    final todaySchedules = medicineProvider.todaySchedules;
    
    final allMedicines = medicineProvider.allMedicines;
    final recentMedicines = allMedicines.take(2).toList(); 

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
                      patientId: _patientId ?? "", // Kirim ID yang sudah dinamis
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

                if (recentMedicines.isEmpty)
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