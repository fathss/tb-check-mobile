import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/widgets/custom_action_button.dart';

class AdminDetailPage extends StatelessWidget {
  const AdminDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const adminName = 'Dr. Budi Utomo';
    const adminEmail = 'admin1@gmail.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          SizedBox(height: 8),
          _AdminProfileCard(name: adminName, email: adminEmail),
          SizedBox(height: 24),
          Text(
            'Aksi Administratif',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          CustomActionButton(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
            icon: Icons.lock_reset_outlined,
            label: 'Reset Password ke Default',
            onPressed: () {},
          ),
          SizedBox(height: 12),
          CustomActionButton(
            backgroundColor: AppColors.warningBg,
            foregroundColor: AppColors.warning,
            icon: Icons.pause_circle_outline,
            label: 'Bekukan Akun (Suspend)',
            onPressed: () {},
          ),
          SizedBox(height: 12),
          CustomActionButton(
            backgroundColor: AppColors.errorBg,
            foregroundColor: AppColors.error,
            icon: Icons.delete_outline,
            label: 'Hapus Permanen Pengguna',
            onPressed: () {},
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AdminProfileCard extends StatelessWidget {
  const _AdminProfileCard({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.cardStroke, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryBg,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
