import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/date_helper.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';
// Sesuaikan import auth_storage ini dengan struktur foldermu
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart'; 

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final DateTime userRegisteredAt = DateTime(2026, 5, 17); // Bisa dibuat dinamis nanti
  late DateTime selectedDate;
  String? currentPatientId; // Sekarang kosong, bukan hardcode lagi

  final List<IconData> medicineIcons = [Icons.medication, Icons.medical_information, Icons.receipt_long, Icons.trip_origin];
  final List<Color> iconBgColors = [const Color(0xFFFFF0D4), const Color(0xFFFFE5F0), const Color(0xFFE0FAFA), const Color(0xFFE8EBFF)];
  final List<Color> iconColors = [const Color(0xFFFF9800), const Color(0xFFE91E63), const Color(0xFF00BCD4), const Color(0xFF673AB7)];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final storage = ref.read(authStorageProvider);
    final userId = await storage.getUserId();
    
    if (userId != null) {
      try {
        final summary = await ref.read(homeSummaryProvider(userId).future);
        setState(() {
          currentPatientId = summary.patientId;
        });
        
        if (currentPatientId != null) {
          if (!mounted) return;
          context.read<MedicineProvider>().fetchScheduleByDate(currentPatientId!, selectedDate);
        }
      } catch (e) {
        print("EXCEPTION CALENDAR: $e");
      }
    }
  }

  Map<String, List<dynamic>> _groupSchedulesByTime(List<dynamic> schedules) {
    Map<String, List<dynamic>> grouped = {};
    for (var schedule in schedules) {
      String rawTime = schedule['time'] ?? "00:00";
      int hour = int.tryParse(rawTime.split(':').first) ?? 0;
      String period = hour >= 12 ? "PM" : "AM";
      String timeKey = "$rawTime $period";

      if (!grouped.containsKey(timeKey)) {
        grouped[timeKey] = [];
      }
      grouped[timeKey]!.add(schedule);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final dates = DateHelper.generateDates(startDate: userRegisteredAt, totalDays: 30);
    
    final medicineProvider = context.watch<MedicineProvider>();
    final schedules = medicineProvider.selectedDateSchedules;
    final groupedSchedules = _groupSchedulesByTime(schedules);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  const Text("Jadwal Keseluruhan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 85,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final isSelected = selectedDate.day == date.day && selectedDate.month == date.month && selectedDate.year == date.year;
                    final dayName = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"][date.weekday - 1];

                    return GestureDetector(
                      onTap: () {
                        setState(() { selectedDate = date; });
                        if (currentPatientId != null) {
                          context.read<MedicineProvider>().fetchScheduleByDate(currentPatientId!, date);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 65,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dayName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade500)),
                            const SizedBox(height: 8),
                            Text(date.day.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: medicineProvider.isCalendarLoading
                    ? const Center(child: CircularProgressIndicator())
                    : groupedSchedules.isEmpty
                        ? Center(child: Text("Tidak ada jadwal pada tanggal ini.", style: TextStyle(color: Colors.grey.shade500)))
                        : ListView.builder(
                            itemCount: groupedSchedules.keys.length,
                            itemBuilder: (context, index) {
                              String timeKey = groupedSchedules.keys.elementAt(index);
                              List<dynamic> schedulesAtTime = groupedSchedules[timeKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(timeKey, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  Divider(color: Colors.grey.shade200, thickness: 1),
                                  const SizedBox(height: 16),
                                  ...schedulesAtTime.map((schedule) {
                                    return _buildGroupedScheduleCard(schedule);
                                  }),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedScheduleCard(dynamic data) {
    bool isDone = data["isDone"] ?? false;
    int imgIndex = data["imageIndex"] ?? 0;
    String scheduleId = data["scheduleId"] ?? ""; 

    if (imgIndex < 0 || imgIndex >= medicineIcons.length) imgIndex = 0;

    return GestureDetector(
      onTap: () async {
        if (isDone || currentPatientId == null) return; 
        
        final success = await context.read<MedicineProvider>().confirmConsume(scheduleId, currentPatientId!);
        
        if (success) {
           if (!mounted) return;
           context.read<MedicineProvider>().fetchScheduleByDate(currentPatientId!, selectedDate);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF2FFF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? Colors.green.shade300 : Colors.transparent),
          boxShadow: isDone ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: iconBgColors[imgIndex], borderRadius: BorderRadius.circular(12)),
              child: Icon(medicineIcons[imgIndex], color: iconColors[imgIndex], size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["title"] ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87, decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none),
                  ),
                  const SizedBox(height: 6),
                  Text(data["subtitle"] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? Colors.green : Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }
}