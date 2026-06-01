import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/core/widgets/app_snackbar.dart';
import 'package:tbcheck_app/features/user_profile/controllers/profile_controller.dart';
import 'package:tbcheck_app/features/user_profile/widgets/profile_input_section.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';
import 'package:tbcheck_app/features/user_profile/data/repositories/user_profile_repository.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final ProfileController controller = ProfileController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => controller.isLoading = true);
    final storage = ref.read(authStorageProvider);
    final userId = await storage.getUserId();

    if (userId != null) {
      final repo = ref.read(userProfileRepositoryProvider);
      final data = await repo.getProfile(userId);

      if (mounted) {
        setState(() {
          controller.populateData(data);
          controller.isLoading = false;
        });
      }
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Edit Profil Pribadi", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NIK
                    ProfileInputSection(
                      title: "NIK",
                      controller: controller.nikController,
                      isBold: true,
                    ),
                    const SizedBox(height: 16),

                    /// FULL NAME
                    ProfileInputSection(
                      title: "Nama Lengkap",
                      controller: controller.nameController,
                      isBold: true,
                    ),
                    const SizedBox(height: 16),

                    /// BIRTH DATE
                    ProfileInputSection(
                      title: "Tanggal Lahir",
                      controller: controller.birthDateController,
                      isBold: true,
                      readOnly: true, // Cegah keyboard muncul
                      suffixIcon: Icons.calendar_month,
                      onSuffixTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2001, 5, 15),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            controller.birthDateController.text =
                                "${picked.day.toString().padLeft(2, '0')}/"
                                "${picked.month.toString().padLeft(2, '0')}/"
                                "${picked.year}";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    /// GENDER
                    const Text("Jenis Kelamin", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => controller.toggleGender(true)),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: controller.isMale ? AppColors.primaryBg : AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: controller.isMale ? AppColors.primary : Colors.transparent, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  "Laki-Laki", 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: controller.isMale ? AppColors.primary : AppColors.textSecondary)
                                )
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => controller.toggleGender(false)),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: !controller.isMale ? AppColors.primaryBg : AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: !controller.isMale ? AppColors.primary : Colors.transparent, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  "Perempuan", 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: !controller.isMale ? AppColors.primary : AppColors.textSecondary)
                                )
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    /// BUTTON SAVE
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: "Simpan Perubahan",
                            onPressed: () async {
                              setState(() => _isSaving = true);
                              
                              final storage = ref.read(authStorageProvider);
                              final userId = await storage.getUserId();

                              if (userId != null) {
                                // Format tanggal dari DD/MM/YYYY ke YYYY-MM-DD
                                List<String> dateParts = controller.birthDateController.text.split('/');
                                String formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}T00:00:00Z";

                                Map<String, dynamic> updateData = {
                                  "fullName": controller.nameController.text,
                                  "nik": controller.nikController.text,
                                  "dateOfBirth": formattedDate,
                                  "gender": controller.isMale ? "Laki-Laki" : "Perempuan",
                                };

                                final repo = ref.read(userProfileRepositoryProvider);
                                bool success = await repo.updateProfile(userId, updateData);

                                if (mounted) {
                                  setState(() => _isSaving = false);
                                  if (success) {
                                    AppSnackbar.showSuccess(context, "Profil berhasil diperbarui");
                                    Navigator.pop(context); // Kembali ke menu profil setelah sukses
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memperbarui profil."), backgroundColor: Colors.red));
                                  }
                                }
                              } else {
                                setState(() => _isSaving = false);
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