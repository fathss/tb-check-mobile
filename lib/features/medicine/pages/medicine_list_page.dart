import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_item_card.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_detail_page.dart';
import 'package:tbcheck_app/features/medicine/pages/add_medicine_page.dart';

class MedicineListPage extends StatelessWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [
              const SizedBox(height: 24),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Daftar Obat",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// LIST
              Expanded(
                child: ListView(
                  children: [
                    MedicineItemCard(
                      title: "Pyrazinamide, 500 mg",

                      subtitle: "3 pill, once per day",

                      schedule: "07:00 am - After Eating",

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineDetailPage(
                              medicineName: "Pyrazinamide, 500 mg",
                              function: "Untuk pengobatan TBC",
                              consumeTimes: ["07:00 AM"],
                              dose: "3 pill, once per day",
                              stock: "30",
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

                    MedicineItemCard(
                      title: "Rifampisin, 450 mg",

                      subtitle: "1 pill, once per day",

                      schedule: "06:00 am - Before Eating",

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineDetailPage(
                              medicineName: "Rifampisin, 450 mg",
                              function: "Antibiotik untuk terapi TBC",
                              consumeTimes: ["06:00 AM"],
                              dose: "1 pill, once per day",
                              stock: "20",
                              condition: "Sebelum Makan",
                              activeDays: const [
                                true,
                                true,
                                true,
                                true,
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
                      title: "Isoniazid, 300 mg",

                      subtitle: "1 pill, once per day",

                      schedule: "08:00 am - Before Eating",

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicineDetailPage(
                              medicineName: "Isoniazid, 300 mg",
                              function: "Membantu membunuh bakteri TBC",
                              consumeTimes: ["08:00 AM"],
                              dose: "1 pill, once per day",
                              stock: "15",
                              condition: "Sebelum Makan",
                              activeDays: const [
                                true,
                                false,
                                true,
                                false,
                                true,
                                false,
                                true,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 24),

                child: PrimaryButton(
                  text: "Tambah Obat",

                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const AddMedicinePage(),
                      ),
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
