import 'package:flutter/material.dart';
import 'package:tbcheck_app/features/medicine/medicine_card.dart';
import 'package:tbcheck_app/features/home/widgets/treatment_progress_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_page.dart';
import '../medicine/providers/medicine_consumption_log_provider.dart';
import '../../core/constants/app_constants.dart';
import '../medicine/providers/medicine_provider.dart';
import '../medicine/pages/medicine_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(
      medicineConsumptionLogsProvider(AppConstants.dummyPatientId),
    );
    final medicinesAsync = ref.watch(
      medicineProvider(AppConstants.dummyPatientId),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 🔹 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Text(
                          "A",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, Aan",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Waktunya Pulih",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.notifications),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔵 CARD PROGRESS
              logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) => Text(e.toString()),

                data: (logs) {
                  final currentDose = logs.length;

                  const totalDose = 180;

                  final progress = currentDose / totalDose;

                  return TreatmentProgressCard(
                    phase: currentDose < 60 ? "Fase Intensif" : "Fase Lanjutan",

                    description:
                        "Kamu telah menyelesaikan "
                        "${(progress * 100).toInt()}% "
                        "dari total pengobatan.",

                    currentDose: currentDose,

                    totalDose: totalDose,

                    progress: progress.clamp(0, 1),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Jadwal Hari ini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // 🔹 LIST JADWAL
              Expanded(
                child: medicinesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Center(child: Text(e.toString())),

                  data: (medicines) {
                    final logs = logsAsync.value ?? [];

                    final cards = <Widget>[];

                    for (final medicine in medicines) {
                      for (final schedule in medicine.schedules) {
                        cards.add(
                          MedicineCard(
                            time: schedule,

                            title: "${medicine.name}, ${medicine.dosage}",

                            subtitle: "1 Tablet, ${medicine.consumeCondition}",

                            isDone: logs.any(
                              (log) =>
                                  log.medicineId == medicine.id &&
                                  log.scheduleTime == schedule,
                            ),

                            onConfirm: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MedicinePage(),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }

                    if (cards.isEmpty) {
                      return const Center(child: Text("Belum ada jadwal obat"));
                    }

                    return ListView(children: cards.take(3).toList());
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
