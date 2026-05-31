import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/medicine/widgets/medicine_item_card.dart';
import 'package:tbcheck_app/features/medicine/pages/medicine_detail_page.dart';
import 'package:tbcheck_app/features/medicine/pages/add_medicine_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/core/constants/app_constants.dart';
import '../providers/medicine_provider.dart';

class MedicineListPage extends ConsumerWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(
      medicineProvider(AppConstants.dummyPatientId),
    );

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
                child: medicinesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Center(child: Text(e.toString())),

                  data: (medicines) {
                    if (medicines.isEmpty) {
                      return const Center(child: Text("Belum ada obat"));
                    }

                    return ListView.builder(
                      itemCount: medicines.length,

                      itemBuilder: (context, index) {
                        final medicine = medicines[index];

                        return MedicineItemCard(
                          title: "${medicine.name}, ${medicine.dosage}",

                          subtitle: medicine.function,

                          schedule: medicine.schedules.join(", "),

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
                      },
                    );
                  },
                ),
              ),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 24),

                child: PrimaryButton(
                  text: "Tambah Obat",

                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddMedicinePage(),
                      ),
                    );

                    ref.invalidate(
                      medicineProvider(AppConstants.dummyPatientId),
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
