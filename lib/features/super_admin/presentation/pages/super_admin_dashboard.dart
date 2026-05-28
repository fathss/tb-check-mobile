import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_management_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/user_admin_management/user_management_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/super_admin_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/dashboard_stat_card.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/dashboard_menu_card.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({
    super.key,
    this.superAdminId = AppConstants.defaultSuperAdminId,
  });

  final String superAdminId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(superAdminDashboardProvider);
    final profileAsync = ref.watch(superAdminProfileProvider(superAdminId));

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
              children: [
                const Text(
                  'IT Administrator',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                profileAsync.when(
                  loading: () => const Text(
                    'Memuat profil...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  error: (error, stackTrace) => const Text(
                    'Super Admin',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  data: (profile) => Text(
                    profile.username,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Gagal memuat dashboard')),
        data: (model) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                DashboardStatCard(
                  icon: Icons.home_work_outlined,
                  iconColor: AppColors.primary,
                  iconBackgroundColor: AppColors.primaryBg,
                  count: model.totalFaskes,
                  suffix: 'Faskes',
                  descriptionText: 'Telah Terdaftar',
                ),
                const SizedBox(height: 12),
                DashboardStatCard(
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: AppColors.magenta,
                  iconBackgroundColor: AppColors.magentaBg,
                  count: model.totalAdmin,
                  suffix: 'Admin',
                  descriptionText: 'Akun Admin Faskses Aktif',
                ),
                const SizedBox(height: 12),
                DashboardStatCard(
                  icon: Icons.people_alt_outlined,
                  iconColor: AppColors.warning,
                  iconBackgroundColor: AppColors.warningBg,
                  count: model.totalPatient,
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
                DashboardMenuCard(
                  icon: Icons.home_work_outlined,
                  iconColor: AppColors.primary,
                  iconBackgroundColor: AppColors.primaryBg,
                  titleText: 'Data Faskes & Akun',
                  descriptionText: 'Kelola Faskes dan akses Adminnya',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FaskesManagementPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                DashboardMenuCard(
                  icon: Icons.people_alt_outlined,
                  iconColor: AppColors.warning,
                  iconBackgroundColor: AppColors.warningBg,
                  titleText: 'Data User Umum',
                  descriptionText: 'Kelola akun pasien atau masyarakat',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UserManagementPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
