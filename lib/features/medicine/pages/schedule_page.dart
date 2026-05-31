import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/date_helper.dart';
// import 'package:tbcheck_app/features/medicine/data/dummy_medicine_data.dart';
import 'package:tbcheck_app/features/medicine/models/medicine_model.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_schedule_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import '../providers/medicine_provider.dart';
import '../models/medicine_consumption_log_model.dart';
import '../providers/medicine_consumption_log_provider.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../utils/medicine_action_helper.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final ScrollController _scrollController = ScrollController();

  /// USER REGISTER DATE
  final DateTime userRegisteredAt = DateTime(2026, 5, 17);

  /// SELECTED DATE
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_scrollController.hasClients) return;

        final todayIndex = DateTime.now().difference(userRegisteredAt).inDays;

        const itemWidth = 84.0;

        _scrollController.jumpTo(todayIndex * itemWidth);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// GENERATED DATES
    final dates = DateHelper.generateDates(
      startDate: userRegisteredAt,
      totalDays: 180,
    );

    final medicinesAsync = ref.watch(
      medicineProvider(AppConstants.dummyPatientId),
    );

    final logsAsync = ref.watch(
      medicineConsumptionLogsProvider(AppConstants.dummyPatientId),
    );

    final logs = logsAsync.value ?? [];

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

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// DATE SELECTOR
              SizedBox(
                height: 95,

                child: ListView.separated(
                  controller: _scrollController,
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
                child: medicinesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Center(child: Text(e.toString())),

                  data: (medicineList) {
                    final filteredMedicines = medicineList.where((medicine) {
                      return !selectedDate.isBefore(medicine.createdAt);
                    }).toList();

                    final Map<String, List<MedicineModel>> groupedMedicines =
                        {};

                    for (final medicine in filteredMedicines) {
                      for (final schedule in medicine.schedules) {
                        groupedMedicines.putIfAbsent(schedule, () => []);

                        groupedMedicines[schedule]!.add(medicine);
                      }
                    }

                    final sortedSchedules = groupedMedicines.keys.toList()
                      ..sort();

                    if (sortedSchedules.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 90,
                              color: AppColors.textSecondary.withOpacity(0.4),
                            ),

                            const SizedBox(height: 20),

                            const Text("Tidak ada jadwal obat"),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: sortedSchedules.length,

                      itemBuilder: (context, index) {
                        final schedule = sortedSchedules[index];

                        final medicines = groupedMedicines[schedule]!;

                        final split = schedule.split(":");

                        final displayTime =
                            "${int.parse(split[0])}:${split[1]}";

                        return Column(
                          children: [
                            ...medicines.map((medicine) {
                              final done = logs.any(
                                (log) =>
                                    log.medicineId == medicine.id &&
                                    log.scheduleTime == schedule &&
                                    log.consumedAt != null &&
                                    log.consumedAt!.year == selectedDate.year &&
                                    log.consumedAt!.month ==
                                        selectedDate.month &&
                                    log.consumedAt!.day == selectedDate.day,
                              );

                              print(
                                "DATE=${selectedDate.toString()} "
                                "MED=${medicine.name} "
                                "TIME=$schedule "
                                "DONE=$done",
                              );
                              return MedicineScheduleCard(
                                medicineId: medicine.id,

                                patientId: medicine.patientId,

                                scheduleTime: schedule,

                                time: displayTime,

                                medicineName:
                                    "${medicine.name}, ${medicine.dosage}",

                                description:
                                    "1 Tablet - ${medicine.consumeCondition.toLowerCase()}",

                                initialDone: logs.any(
                                  (log) =>
                                      log.medicineId == medicine.id &&
                                      log.scheduleTime == schedule &&
                                      log.consumedAt != null &&
                                      log.consumedAt!.year ==
                                          selectedDate.year &&
                                      log.consumedAt!.month ==
                                          selectedDate.month &&
                                      log.consumedAt!.day == selectedDate.day,
                                ),
                                //initialDone: done,
                                onChanged: (value) async {
                                  if (!value) return;

                                  try {
                                    await MedicineActionHelper.markAsTaken(
                                      ref: ref,
                                      medicine: medicine,
                                      scheduleTime: schedule,
                                    );

                                    if (context.mounted) {
                                      AppSnackbar.showSuccess(
                                        context,
                                        "Obat berhasil ditandai telah diminum",
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      AppSnackbar.showError(
                                        context,
                                        "Gagal menyimpan konsumsi obat",
                                      );
                                    }
                                  }
                                },
                              );
                            }),
                          ],
                        );
                      },
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
