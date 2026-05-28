import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/date_helper.dart';
import 'package:tbcheck_app/features/medicine/data/dummy_medicine_data.dart';
import 'package:tbcheck_app/features/medicine/models/medicine_model.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_schedule_card.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  /// USER REGISTER DATE
  final DateTime userRegisteredAt = DateTime(2026, 5, 17);

  /// SELECTED DATE
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    /// GENERATED DATES
    final dates = DateHelper.generateDates(
      startDate: userRegisteredAt,
      totalDays: 30,
    );

    /// FILTER MEDICINES BASED ON DATE
    final filteredMedicines = medicineList.where((medicine) {
      return !selectedDate.isBefore(medicine.createdAt);
    }).toList();

    /// GROUP MEDICINES BY SCHEDULE
    final Map<String, List<MedicineModel>> groupedMedicines = {};

    for (final medicine in filteredMedicines) {
      for (final schedule in medicine.schedules) {
        if (!groupedMedicines.containsKey(schedule)) {
          groupedMedicines[schedule] = [];
        }

        groupedMedicines[schedule]!.add(medicine);
      }
    }

    /// SORT TIME
    final sortedSchedules = groupedMedicines.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 24),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Jadwal Keseluruhan",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// DATE SELECTOR
              SizedBox(
                height: 95,

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  itemCount: dates.length,

                  separatorBuilder: (_, __) => const SizedBox(width: 14),

                  itemBuilder: (context, index) {
                    final date = dates[index];

                    final isSelected =
                        selectedDate.day == date.day &&
                        selectedDate.month == date.month &&
                        selectedDate.year == date.year;

                    final dayName = [
                      "Sen",
                      "Sel",
                      "Rab",
                      "Kam",
                      "Jum",
                      "Sab",
                      "Min",
                    ][date.weekday - 1];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),

                        width: 70,

                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,

                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(
                              dayName,

                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,

                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              date.day.toString(),

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,

                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              /// CONTENT
              Expanded(
                child: sortedSchedules.isEmpty
                    /// EMPTY STATE
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 90,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Tidak ada jadwal obat",

                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Tidak ada obat yang perlu diminum hari ini",

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    /// LIST
                    : ListView.builder(
                        itemCount: sortedSchedules.length,

                        itemBuilder: (context, index) {
                          final schedule = sortedSchedules[index];

                          final medicines = groupedMedicines[schedule]!;

                          final split = schedule.split(":");

                          final hour = int.parse(split[0]);

                          final minute = split[1];

                          final displayTime = "$hour:$minute";
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              /// MEDICINE LIST
                              ...medicines.map((medicine) {
                                return MedicineScheduleCard(
                                  time: displayTime,

                                  medicineName:
                                      "${medicine.name}, ${medicine.dosage}",

                                  description:
                                      "1 Tablet - ${medicine.consumeCondition.toLowerCase()}",

                                  initialDone: medicine.isCompleted,
                                );
                              }),

                              const SizedBox(height: 5),
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
}
