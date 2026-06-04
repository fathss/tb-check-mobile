import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' hide Provider; 
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/medicine/controllers/medicine_detail_controller.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_input_section.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_day_selector.dart';
import 'package:tbcheck_app/features/medicine/providers/medicine_provider.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';
// Import Auth Storage untuk mengambil ID dinamis
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class AddMedicinePage extends ConsumerStatefulWidget {
  const AddMedicinePage({super.key});

  @override
  ConsumerState<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends ConsumerState<AddMedicinePage> {
  final MedicineDetailController controller = MedicineDetailController();
  
  // State untuk melacak proses loading saat tombol Save ditekan
  bool _isSaving = false;

  final List<String> dayNames = ["Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu", "Minggu"];

  final List<IconData> medicineIcons = [
    Icons.medication,
    Icons.medical_information,
    Icons.receipt_long,
    Icons.trip_origin,
  ];

  final List<Color> iconBgColors = [
    const Color(0xFFFFF0D4),
    const Color(0xFFFFE5F0),
    const Color(0xFFE0FAFA),
    const Color(0xFFE8EBFF),
  ];

  final List<Color> iconColors = [
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFF673AB7),
  ];

  @override
  void initState() {
    super.initState();
    controller.init(
      medicineName: "",
      function: "",
      dose: "",
      stock: "",
      condition: "Sebelum Makan",
      days: [true, false, false, true, false, false, false],
      consumeTimes: ["06:00 AM"], 
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24, color: Colors.black87), 
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Create New Medicine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// NAME
              MedicineInputSection(
                title: "Medicine Name",
                controller: controller.medicineNameController,
                isBold: true,
              ),
              const SizedBox(height: 12),

              /// FUNCTION
              MedicineInputSection(
                title: "Tujuan / Fungsi Obat",
                controller: controller.functionController,
                isBold: true,
              ),
              const SizedBox(height: 12),

              /// DOSAGE & STOCK
              Row(
                children: [
                  Expanded(
                    child: MedicineInputSection(
                      title: "Dosis (pil)",
                      controller: controller.doseController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MedicineInputSection(
                      title: "Stok Total",
                      controller: controller.stockController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), 

              /// DISPLAY IMAGE
              const Text("Display Image", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), 
              Wrap(
                spacing: 12, 
                children: List.generate(medicineIcons.length, (index) {
                  final isSelected = controller.selectedImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.changeImage(index);
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBgColors[index],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? iconColors[index] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(medicineIcons[index], color: iconColors[index], size: 20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              /// CONDITION
              const Text("Kondisi Minum", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () { setState(() { controller.changeCondition("Sebelum Makan"); }); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.selectedCondition == "Sebelum Makan" ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Sebelum Makan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: controller.selectedCondition == "Sebelum Makan" ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () { setState(() { controller.changeCondition("Setelah Makan"); }); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.selectedCondition == "Setelah Makan" ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Setelah Makan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: controller.selectedCondition == "Setelah Makan" ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// WAKTU MINUM
              const Text("Waktu Minum", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...List.generate(
                    controller.consumeTimeControllers.length,
                    (index) {
                      return GestureDetector(
                        onTap: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            final hour = pickedTime.hourOfPeriod.toString().padLeft(2, '0');
                            final minute = pickedTime.minute.toString().padLeft(2, '0');
                            final period = pickedTime.period == DayPeriod.am ? "AM" : "PM";
                            setState(() {
                              controller.consumeTimeControllers[index].text = "$hour:$minute $period";
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.consumeTimeControllers[index].text,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              if (controller.consumeTimeControllers.length > 1) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () { setState(() { controller.removeConsumeTime(index); }); },
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // --- UBAH BAGIAN TOMBOL TAMBAH INI ---
                  GestureDetector(
                    onTap: () async { 
                      // 1. Langsung munculkan pemilih waktu saat "Tambah +" ditekan
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      
                      // 2. Jika user memilih waktu (tidak tekan cancel)
                      if (pickedTime != null) {
                        final hour = pickedTime.hourOfPeriod.toString().padLeft(2, '0');
                        final minute = pickedTime.minute.toString().padLeft(2, '0');
                        final period = pickedTime.period == DayPeriod.am ? "AM" : "PM";
                        
                        setState(() { 
                          // 3. Buat kotak biru baru
                          controller.addConsumeTime(); 
                          // 4. Langsung isi kotak terakhir yang baru dibuat dengan jam pilihan
                          controller.consumeTimeControllers.last.text = "$hour:$minute $period";
                        }); 
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(16)),
                      child: const Text("Tambah +", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// HARI PER MINGGU
              const Text("Hari per Minggu", style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MedicineDaySelector(
                activeDays: controller.activeDays,
                onToggle: (index) { setState(() { controller.toggleDay(index); }); },
              ),
              const SizedBox(height: 24),

              /// BUTTON SAVE
              _isSaving 
                ? const Center(child: CircularProgressIndicator()) 
                : PrimaryButton(
                    text: "Save Schedule",
                    onPressed: () async {
                      // 1. Ubah UI ke state Loading
                      setState(() {
                        _isSaving = true;
                      });

                      try {
                        // 2. Ambil User ID Dinamis dari Storage
                        final storage = ref.read(authStorageProvider);
                        final userId = await storage.getUserId();

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sesi tidak ditemukan. Silakan login kembali."), backgroundColor: Colors.red));
                          return;
                        }

                        // 3. Ambil Patient ID dari Profil
                        final summary = await ref.read(homeSummaryProvider(userId).future);
                        final patientId = summary.patientId;
                        
                        if (patientId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil Medis belum terdaftar."), backgroundColor: Colors.red));
                          return;
                        }

                        // 4. Bersihkan Format Jam
                        List<String> cleanTimes = controller.consumeTimeControllers.map((c) {
                          return c.text.replaceAll(" AM", "").replaceAll(" PM", "").trim();
                        }).toList();

                        // 5. Kirim data ke API C#
                        bool success = await context.read<MedicineProvider>().addMedicine(
                          patientId: patientId, // <-- SEKARANG SUDAH DINAMIS!
                          name: controller.medicineNameController.text,
                          function: controller.functionController.text,
                          dosage: controller.doseController.text,
                          stock: int.tryParse(controller.stockController.text) ?? 0,
                          imageIndex: controller.selectedImageIndex,
                          condition: controller.selectedCondition,
                          activeDays: controller.activeDays,
                          consumeTimes: cleanTimes,
                        );

                        if (!context.mounted) return;
                        
                        // 6. Tangani Hasil (Sukses / Gagal)
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jadwal obat berhasil ditambahkan!"), backgroundColor: Colors.green));
                          Navigator.pop(context); 
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan obat. Periksa koneksi Anda."), backgroundColor: Colors.red));
                        }
                      } catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan sistem: $e"), backgroundColor: Colors.red));
                         }
                      } finally {
                        // 7. Kembalikan UI dari state Loading
                        if (mounted) {
                          setState(() {
                            _isSaving = false;
                          });
                        }
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}