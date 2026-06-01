import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class MedicineDetailPage extends StatelessWidget {
  final String medicineName;
  final String function;
  final List<String> consumeTimes;
  final String dose;
  final String condition;
  final List<bool> activeDays;
  final String stock;

  const MedicineDetailPage({
    super.key,
    required this.medicineName,
    required this.function,
    required this.consumeTimes,
    required this.dose,
    required this.condition,
    required this.activeDays,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: const Icon(Icons.arrow_back, size: 28, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ICON BOX
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0FAFA), // Cyan muda
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF00BCD4), // Cyan tegas
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// MEDICINE NAME
                      _buildInfoSection("Medicine Name", medicineName, isBold: true, isBlack: true),
                      const SizedBox(height: 16),

                      /// FUNGSI
                      _buildInfoSection("Fungsi", function),
                      const SizedBox(height: 12),
                      
                      /// GARIS PEMBATAS TIPIS
                      Divider(color: Colors.grey.shade200, thickness: 1),
                      const SizedBox(height: 16),

                      /// WAKTU MINUM (Pill Shape)
                      Text(
                        "Waktu Minum",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: consumeTimes.map((time) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              time,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      /// DOSIS
                      _buildInfoSection("Dosis", dose),
                      const SizedBox(height: 20),

                      /// KONDISI
                      _buildInfoSection("Kondisi", condition),
                      const SizedBox(height: 24),

                      /// HARI PER MINGGU
                      Text(
                        "Hari per Minggu",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final days = ["Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu", "Minggu"];
                          final isActive = activeDays.length > index ? activeDays[index] : false;

                          return Column(
                            children: [
                              Text(
                                days[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isActive ? AppColors.primary : Colors.grey.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              /// BUTTON CHANGE SCHEDULE
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: PrimaryButton(
                  text: "Change Schedule",
                  onPressed: () {
                    // Nanti logika navigasi untuk Edit akan dipasang di sini
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper agar kodenya lebih rapi
  Widget _buildInfoSection(String title, String value, {bool isBold = false, bool isBlack = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isBlack ? Colors.black87 : Colors.grey.shade500,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}