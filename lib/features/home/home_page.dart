import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
// import 'package:tbcheck_app/features/medicine/pages/medicine_page.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_schedule_card.dart';
import 'package:tbcheck_app/features/medicine/pages/schedule_page.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
// import 'package:tbcheck_app/core/widgets/app_snackbar.dart';
// import 'package:tbcheck_app/features/medicine/pages/schedule_page.dart';
import 'package:tbcheck_app/features/home/widgets/treatment_progress_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.third,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 16),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      /// PROFILE
                      Container(
                        width: 58,
                        height: 58,

                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,

                          shape: BoxShape.circle,
                        ),

                        child: const Center(
                          child: Text(
                            "A",

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,

                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// TEXT
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Halo, Aan",

                            style: TextStyle(
                              fontSize: 13,

                              color: AppColors.textSecondary,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Waktunya Pulih",

                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /// NOTIFICATION
                  Container(
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Icon(Icons.notifications_none, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              TreatmentProgressCard(
                phase: "Fase Intensif",

                description:
                    "Kamu telah menyelesaikan 55% dari total pengobatan. Terus semangat!",

                currentDose: 45,

                totalDose: 180,

                progress: 0.55,
              ),
              const SizedBox(height: 32),

              /// SCHEDULE HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Jadwal Hari Ini",

                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(builder: (_) => const SchedulePage()),
                      );
                    },

                    child: const Text(
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

              /// SCHEDULE LIST
              const MedicineScheduleCard(
                time: "06:00",

                medicineName: "Rifampisin, 450 mg",

                description: "1 Tablet - sebelum makan",

                initialDone: true,
              ),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  border: Border.all(color: AppColors.cardStroke, width: 2),
                ),

                child: Column(
                  children: [
                    MedicineScheduleCard(
                      time: "19:00",

                      medicineName: "Vitamin B6",

                      description: "1 Tablet, Sesudah Makan",

                      initialDone: false,
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: "Konfirmasi Minum",

                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const SchedulePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
