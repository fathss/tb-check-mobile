import 'package:flutter/material.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import '../pages/schedule_page.dart';
import '../widgets/medicine_schedule_card.dart';
import '../widgets/medicine_item_card.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_detail_page.dart';

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
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

                const MedicineScheduleCard(
                  time: "06:00",

                  medicineName: "Rifampisin",
                  description: "1 Tablet, Sebelum Makan",
                  initialDone: true,
                ),

                const MedicineScheduleCard(
                  time: "19:00",
                  medicineName: "Rifampisin",
                  description: "1 Tablet, Sebelum Makan",
                  initialDone: false,
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Daftar Obat Anda",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Lihat Semua",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                MedicineItemCard(
                  title: "Pyrazinamide, 500 mg",
                  subtitle: "3 pill, once per day",
                  schedule: "07:00 am - Sebelum Makan",

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicineDetailPage(
                          medicineName: "Pyrazinamide, 500 mg",
                          function: "Untuk pengobatan TBC",
                          consumeTimes: ["07:00 AM"],
                          dose: "3 pill, once per day",
                          condition: "Sebelum Makan",
                          activeDays: const [
                            true,
                            false,
                            true,
                            false,
                            true,
                            false,
                            false,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                MedicineItemCard(
                  title: "Pyrazinamide, 500 mg",
                  subtitle: "3 pill, once per day",
                  schedule: "07:00 am - Sesudah Makan",

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicineDetailPage(
                          medicineName: "Pyrazinamide, 500 mg",
                          function: "Untuk pengobatan TBC",
                          consumeTimes: ["07:00 AM"],
                          dose: "3 pill, once per day",
                          condition: "Sesudah Makan",
                          activeDays: const [
                            true,
                            false,
                            true,
                            false,
                            true,
                            false,
                            false,
                          ],
                        ),
                      ),
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
