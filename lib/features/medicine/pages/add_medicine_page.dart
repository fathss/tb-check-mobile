import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/medicine/controllers/medicine_detail_controller.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_input_section.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_day_selector.dart';
import 'package:tbcheck_app/core/widgets/app_snackbar.dart';
import 'package:tbcheck_app/features/medicine/models/medicine_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medicine_provider.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';

class AddMedicinePage extends ConsumerStatefulWidget {
  const AddMedicinePage({super.key});

  @override
  ConsumerState<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends ConsumerState<AddMedicinePage> {
  final MedicineDetailController controller = MedicineDetailController();

  final List<String> dayNames = [
    "Sen",
    "Sel",
    "Rab",
    "Kam",
    "Jum",
    "Sab",
    "Min",
  ];

  final List<IconData> medicineIcons = [
    Icons.medication,
    Icons.medical_services,
    Icons.receipt_long,
    Icons.circle,
  ];

  final List<Color> iconBgColors = [
    const Color(0xFFFFE8CC),
    const Color(0xFFFFD6EC),
    const Color(0xFFD7F5FF),
    const Color(0xFFDCE2FF),
  ];

  final List<Color> iconColors = [
    Colors.orange,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
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

      consumeTimes: ["06:00"],
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Future<void> pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');

      final minute = picked.minute.toString().padLeft(2, '0');

      setState(() {
        controller.consumeTimeControllers[index].text = "$hour:$minute";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

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
                    "Tambah obat",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              /// NAME
              MedicineInputSection(
                title: "Nama Obat",

                controller: controller.medicineNameController,

                isBold: true,
              ),

              const SizedBox(height: 16),

              /// FUNCTION
              MedicineInputSection(
                title: "Fungsi",

                controller: controller.functionController,

                isBold: true,
              ),

              const SizedBox(height: 16),

              /// DOSAGE & STOCK
              Row(
                children: [
                  Expanded(
                    child: MedicineInputSection(
                      title: "Dosis (pil)",

                      controller: controller.doseController,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: MedicineInputSection(
                      title: "Stok Obat",

                      controller: controller.stockController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// IMAGE
              const Text(
                "Display Image",

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: List.generate(medicineIcons.length, (index) {
                  final isSelected = controller.selectedImageIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.changeImage(index);
                      });
                    },

                    child: Container(
                      width: 70,
                      height: 70,

                      margin: const EdgeInsets.only(right: 16),

                      decoration: BoxDecoration(
                        color: iconBgColors[index],

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,

                          width: 1,
                        ),
                      ),

                      child: Icon(
                        medicineIcons[index],

                        color: iconColors[index],

                        size: 20,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              /// CONDITION
              const Text(
                "Kondisi Minum",

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.changeCondition("Sebelum Makan");
                        });
                      },

                      child: Container(
                        height: 58,

                        decoration: BoxDecoration(
                          color: controller.selectedCondition == "Sebelum Makan"
                              ? AppColors.primary
                              : AppColors.secondary,

                          borderRadius: BorderRadius.circular(24),
                        ),

                        child: Center(
                          child: Text(
                            "Sebelum Makan",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              color:
                                  controller.selectedCondition ==
                                      "Sebelum Makan"
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.changeCondition("Setelah Makan");
                        });
                      },

                      child: Container(
                        height: 58,

                        decoration: BoxDecoration(
                          color: controller.selectedCondition == "Setelah Makan"
                              ? AppColors.primary
                              : AppColors.secondary,

                          borderRadius: BorderRadius.circular(24),
                        ),

                        child: Center(
                          child: Text(
                            "Setelah Makan",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              color:
                                  controller.selectedCondition ==
                                      "Setelah Makan"
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                "Waktu Minum",

                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Column(
                children: List.generate(
                  controller.consumeTimeControllers.length,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              Color.fromRGBO(79, 141, 253, 1),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  pickTime(index);
                                },

                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: controller
                                        .consumeTimeControllers[index],

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),

                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (controller.consumeTimeControllers.length > 1)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.removeConsumeTime(index);
                                  });
                                },

                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    controller.addConsumeTime();
                  });
                },

                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "Tambah Jadwal",

                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// DAYS
              MedicineDaySelector(
                activeDays: controller.activeDays,

                onToggle: (index) {
                  setState(() {
                    controller.toggleDay(index);
                  });
                },
              ),

              const SizedBox(height: 40),

              /// BUTTON
              PrimaryButton(
                text: "Save Schedule",

                onPressed: () async {
                  try {
                    final medicine = MedicineModel(
                      id: '',
                      patientId: AppConstants.dummyPatientId,

                      name: controller.medicineNameController.text,

                      function: controller.functionController.text,

                      dosage: controller.doseController.text,

                      stock: int.tryParse(controller.stockController.text) ?? 0,

                      schedules: controller.consumeTimeControllers
                          .map((e) => e.text)
                          .toList(),

                      consumeCondition: controller.selectedCondition,

                      activeDays: controller.activeDays,

                      selectedImageIndex: controller.selectedImageIndex,

                      isCompleted: false,

                      createdAt: DateTime.now(),
                    );

                    await ref
                        .read(medicineRepositoryProvider)
                        .createMedicine(medicine);

                    if (!mounted) return;

                    AppSnackbar.showSuccess(
                      context,
                      "Obat berhasil ditambahkan",
                    );

                    ref.invalidate(
                      medicineProvider(AppConstants.dummyPatientId),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    AppSnackbar.showError(context, e.toString());
                  }
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
