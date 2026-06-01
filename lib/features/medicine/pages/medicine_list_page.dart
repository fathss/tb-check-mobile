import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_item_card.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_detail_page.dart';
import 'package:tbcheck_app/features/medicine/pages/add_medicine_page.dart';

class MedicineListPage extends StatelessWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data dari Provider
    final medicineProvider = context.watch<MedicineProvider>();
    final medicines = medicineProvider.allMedicines;

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
                    child: const Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Daftar Obat",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// LIST OBAT (Dinamis dari Backend)
              Expanded(
                child: medicines.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada obat yang ditambahkan",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          final med = medicines[index];
                          
                          // Parsing JSON string jadwal menjadi List
                          List<dynamic> times = [];
                          if (med['schedulesJson'] != null) {
                            try {
                              times = jsonDecode(med['schedulesJson']);
                            } catch (e) {
                              times = [];
                            }
                          }
                          
                          // Parsing JSON string hari aktif
                          List<dynamic> activeDaysDyn = [];
                          if (med['activeDaysJson'] != null) {
                            try {
                              activeDaysDyn = jsonDecode(med['activeDaysJson']);
                            } catch (e) {
                              activeDaysDyn = [];
                            }
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
                        },
                      ),
              ),

              /// BUTTON ADD NEW MEDICINE
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: PrimaryButton(
                  text: "Add new medicine",
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