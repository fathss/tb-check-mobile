import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/custom_text_field.dart';
import 'package:tbcheck_app/features/super_admin/widgets/custom_button.dart';

class SuperAdminProfilePage extends StatelessWidget {
  const SuperAdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          titleSpacing: 20,
          title: const Text(
            'Profil Saya',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              color: AppColors.error,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardStroke,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryBg,
                      child: const Text(
                        'I',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Column(
                  children: const [
                    // Nama Administrator
                    CustomTextField(
                      label: 'Nama Administrator',
                      initialValue: 'IT Support TBCheck',
                    ),

                    // Email Sistem (Read Only)
                    CustomTextField(
                      label: 'Email Sistem',
                      subLabel: '(tidak dapat dirubah)',
                      initialValue: 'admin@tbcare.id',
                      readOnly: true,
                    ),

                    // Ganti Kata Sandi
                    CustomTextField(
                      label: 'Ganti Kata Sandi',
                      hintText: 'Masukkan kata sandi baru...',
                      footerNote:
                          'Biarkan kosong jika tidak ingin merubah kata sandi',
                      obscureText: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Simpan Perubahan',
                    onPressed: () {},
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
