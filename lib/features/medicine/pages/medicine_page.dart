import 'package:flutter/material.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import '../pages/schedule_page.dart';
import '../widgets/medicine_schedule_card.dart';
import '../widgets/medicine_item_card.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_detail_page.dart';
import '../pages/medicine_list_page.dart';
import '../models/medicine_model.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medicine_provider.dart';
import '../providers/medicine_consumption_log_provider.dart';
import '../utils/medicine_action_helper.dart';
import '../../../core/widgets/app_snackbar.dart';

class MedicinePage extends ConsumerWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manajemen Obat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      "Jadwal Hari Ini",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SchedulePage(),
                          ),
                        );
                      },

                      child: Text(
                        "Lihat Kalender",

                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                medicinesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Text(e.toString()),

                  data: (medicines) {
                    final todaySchedules = <Widget>[];

                    for (final medicine in medicines) {
                      for (final schedule in medicine.schedules) {
                        todaySchedules.add(
                          MedicineScheduleCard(
                            medicineId: medicine.id,
                            patientId: medicine.patientId,
                            scheduleTime: schedule,

                            time: schedule,

                            medicineName:
                                "${medicine.name}, ${medicine.dosage}",

                            description:
                                "1 Tablet - ${medicine.consumeCondition}",

                            initialDone: logs.any(
                              (log) =>
                                  log.medicineId == medicine.id &&
                                  log.scheduleTime == schedule,
                            ),

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
                              } catch (_) {
                                if (context.mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    "Gagal menyimpan konsumsi obat",
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }
                    }

                    return Column(children: todaySchedules.take(3).toList());
                  },
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      "Daftar Obat Anda",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MedicineListPage(),
                          ),
                        );
                      },

                      child: const Text(
                        "Lihat Semua",

                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                medicinesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Text(e.toString()),

                  data: (medicines) {
                    if (medicines.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text("Belum ada obat"),
                        ),
                      );
                    }

                    return Column(
                      children: medicines.take(3).map((medicine) {
                        final firstSchedule = medicine.schedules.isNotEmpty
                            ? medicine.schedules.first
                            : "-";

                        return MedicineItemCard(
                          title: "${medicine.name}, ${medicine.dosage}",

                          subtitle: "Stok ${medicine.stock} tablet",

                          schedule:
                              "$firstSchedule - ${medicine.consumeCondition}",

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MedicineDetailPage(medicine: medicine),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
