import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class SuperAdminDashboard extends StatelessWidget {
  final int totalFaskes = 13;
  final int totalAdmin = 35;
  final int totalUser = 15420;

  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBg,
                border: Border.all(color: AppColors.primaryBg, width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'IT Administrator',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.errorBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                child: const Icon(
                  Icons.logout,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Sistem',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _StatusCard(
                icon: Icons.home_work_outlined,
                iconColor: AppColors.primary,
                iconBackgroundColor: AppColors.primaryBg,
                count: totalFaskes,
                suffix: 'Faskes',
                descriptionText: 'Telah Terdaftar',
              ),
              const SizedBox(height: 12),
              _StatusCard(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppColors.magenta,
                iconBackgroundColor: AppColors.magentaBg,
                count: totalAdmin,
                suffix: 'Admin',
                descriptionText: 'Akun Admin Faskses Aktif',
              ),
              const SizedBox(height: 12),
              _StatusCard(
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.warning,
                iconBackgroundColor: AppColors.warningBg,
                count: totalUser,
                suffix: 'User',
                descriptionText: 'Akun Masyarakat Umum',
              ),
              const SizedBox(height: 24),
              const Text(
                'Menu Manajemen',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                icon: Icons.home_work_outlined,
                iconColor: AppColors.primary,
                iconBackgroundColor: AppColors.primaryBg,
                titleText: 'Data Faskes & Akun',
                descriptionText: 'Kelola Faskes dan akses Adminnya',
              ),
              const SizedBox(height: 12),
              _MenuCard(
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.warning,
                iconBackgroundColor: AppColors.warningBg,
                titleText: 'Data User Umum',
                descriptionText: 'Kelola akun pasien atau masyarakat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatWithDots(int value) {
  final sign = value < 0 ? '-' : '';
  final s = value.abs().toString();
  final formatted = s.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return '$sign$formatted';
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final int count;
  final String? suffix;
  final String descriptionText;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.count,
    this.suffix,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    final countText = (suffix == null || suffix!.isEmpty)
        ? formatWithDots(count)
        : '${formatWithDots(count)} $suffix';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.third,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardStroke, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  countText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descriptionText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String titleText;
  final String descriptionText;

  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.titleText,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descriptionText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
