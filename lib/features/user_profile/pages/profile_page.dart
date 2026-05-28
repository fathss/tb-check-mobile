import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/features/user_profile/controllers/profile_controller.dart';
import 'package:tbcheck_app/features/user_profile/widgets/profile_input_section.dart';
import 'package:tbcheck_app/core/widgets/app_snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController controller = ProfileController();

  @override
  void initState() {
    super.initState();

    controller.init(
      nik: "3213124342342",

      fullName: "User Pengguna",

      email: "user123@gmail.com",

      password: "#admin1234",

      birthDate: "15/05/2001",

      gender: true,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 24),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Profil Saya",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  GestureDetector(
                    onTap: () {},

                    child: const Icon(Icons.logout_rounded, size: 34),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// PROFILE IMAGE
              Center(
                child: Container(
                  width: 140,
                  height: 140,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppColors.secondary,

                    border: Border.all(color: Colors.grey.shade100, width: 4),
                  ),

                  child: Center(
                    child: Text(
                      controller.emailController.text[0].toUpperCase(),

                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,

                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// NIK
              ProfileInputSection(
                title: "NIK",

                controller: controller.nikController,

                isBold: true,

                suffixIcon: Icons.edit,
              ),

              const SizedBox(height: 14),

              /// FULL NAME
              ProfileInputSection(
                title: "Nama Lengkap",

                controller: controller.nameController,

                isBold: true,

                suffixIcon: Icons.edit,
              ),

              const SizedBox(height: 14),

              /// EMAIL
              ProfileInputSection(
                title: "Email Terdaftar",

                controller: controller.emailController,

                isBold: true,
                readOnly: true,
              ),

              const SizedBox(height: 14),

              /// PASSWORD
              ProfileInputSection(
                title: "Kata Sandi",

                controller: controller.passwordController,

                isBold: true,

                readOnly: true,

                obscureText: controller.obscurePassword,

                suffixIcon: controller.obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,

                onSuffixTap: () {
                  setState(() {
                    controller.togglePassword();
                  });
                },
              ),

              const SizedBox(height: 14),

              /// BIRTH DATE
              ProfileInputSection(
                title: "Tanggal Lahir",

                controller: controller.birthDateController,

                isBold: true,

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
              const Text(
                "Jenis Kelamin",

                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.toggleGender(true);
                        });
                      },

                      child: Container(
                        height: 72,

                        decoration: BoxDecoration(
                          color: controller.isMale
                              ? AppColors.primaryBg
                              : AppColors.secondary,

                          borderRadius: BorderRadius.circular(22),

                          border: Border.all(
                            color: controller.isMale
                                ? AppColors.primary
                                : Colors.transparent,

                            width: 2,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            "Laki-Laki",

                            style: TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.bold,

                              color: controller.isMale
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.toggleGender(false);
                        });
                      },

                      child: Container(
                        height: 72,

                        decoration: BoxDecoration(
                          color: !controller.isMale
                              ? AppColors.primaryBg
                              : AppColors.secondary,

                          borderRadius: BorderRadius.circular(22),

                          border: Border.all(
                            color: !controller.isMale
                                ? AppColors.primary
                                : Colors.transparent,

                            width: 2,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            "Perempuan",

                            style: TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.bold,

                              color: !controller.isMale
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              /// BUTTON
              PrimaryButton(
                text: "Perbarui Profil",

                onPressed: () {
                  AppSnackbar.showSuccess(
                    context,
                    "Profil berhasil diperbarui",
                  );
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
