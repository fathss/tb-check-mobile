import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/medicine_detail_controller.dart';

import '../widgets/medicine_day_selector.dart';
import '../widgets/medicine_input_section.dart';

class MedicineDetailPage extends StatefulWidget {
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
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final controller = MedicineDetailController();

  @override
  void initState() {
    super.initState();

    controller.init(
      medicineName: widget.medicineName,
      function: widget.function,
      consumeTimes: widget.consumeTimes,
      dose: widget.dose,
      condition: widget.condition,
      days: widget.activeDays,
      stock: widget.stock,
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
      backgroundColor: AppColors.third,

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),

              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(width: 5),

                        const Text(
                          "Informasi",

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// ICON
                    Container(
                      width: 100,
                      height: 100,

                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// MEDICINE NAME
                    MedicineInputSection(
                      title: "Nama Obat",
                      controller: controller.medicineNameController,
                      isBold: true,
                    ),

                    /// FUNCTION
                    MedicineInputSection(
                      title: "Fungsi",
                      controller: controller.functionController,
                      isBold: true,
                    ),

                    /// STOCK OBAT
                    MedicineInputSection(
                      title: "Stok Obat",
                      controller: controller.stockController,
                      isBold: true,
                    ),

                    /// TIME
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
                                      onTap: () async {
                                        final TimeOfDay? pickedTime =
                                            await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );

                                        if (pickedTime != null) {
                                          final hour = pickedTime.hourOfPeriod
                                              .toString()
                                              .padLeft(2, '0');

                                          final minute = pickedTime.minute
                                              .toString()
                                              .padLeft(2, '0');

                                          final period =
                                              pickedTime.period == DayPeriod.am
                                              ? "AM"
                                              : "PM";

                                          setState(() {
                                            controller
                                                    .consumeTimeControllers[index]
                                                    .text =
                                                "$hour:$minute $period";
                                          });
                                        }
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

                                  if (controller.consumeTimeControllers.length >
                                      1)
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

                    /// DOSIS
                    MedicineInputSection(
                      title: "Dosis",
                      controller: controller.doseController,
                      isBold: true,
                    ),

                    /// KONDISI
                    Text(
                      "Kondisi",

                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: controller.selectedCondition,

                      items: const [
                        DropdownMenuItem(
                          value: "Sebelum Makan",
                          child: Text("Sebelum Makan"),
                        ),

                        DropdownMenuItem(
                          value: "Sesudah Makan",
                          child: Text("Sesudah Makan"),
                        ),
                      ],

                      onChanged: (value) {
                        setState(() {
                          controller.changeCondition(value!);
                        });
                      },

                      decoration: InputDecoration(
                        filled: true,

                        fillColor: Colors.white,

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide(color: AppColors.secondary),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide(color: AppColors.secondary),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),

                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// HARI
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
                      text: "Save Changes",

                      onPressed: () {
                        AppSnackbar.showSuccess(
                          context,
                          "Medicine schedule updated successfully",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
