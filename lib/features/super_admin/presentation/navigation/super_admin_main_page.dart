import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/constants/app_constants.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/super_admin_dashboard.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/super_admin_profile_page.dart';

class SuperAdminMainPage extends StatefulWidget {
  const SuperAdminMainPage({
    super.key,
    this.superAdminId = AppConstants.defaultSuperAdminId,
  });

  final String superAdminId;

  @override
  State<SuperAdminMainPage> createState() => _SuperAdminMainPageState();
}

class _SuperAdminMainPageState extends State<SuperAdminMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SuperAdminDashboard(superAdminId: widget.superAdminId),
      SuperAdminProfilePage(superAdminId: widget.superAdminId),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.cardStroke, width: 1.0),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Icon(
                    Icons.home_outlined,
                    color: _currentIndex == 0
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: const Icon(Icons.home, color: AppColors.primary),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Icon(
                    Icons.person_outline,
                    color: _currentIndex == 1
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
