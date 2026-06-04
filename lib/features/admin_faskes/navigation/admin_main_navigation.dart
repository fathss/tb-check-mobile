import 'package:flutter/material.dart';
import '../dashboard/pages/admin_dashboard_screen.dart';
import '../patients/pages/patient_list_page.dart';
// 1. TAMBAHKAN IMPORT MAP DISINI
import '../map_tracking/pages/admin_map_page.dart';
import '../profile/screens/admin_profile_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({Key? key}) : super(key: key);

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  // 2. MASUKKAN HALAMAN MAP KE DALAM LIST
  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const PatientListPage(),
    const AdminMapPage(), // <-- Menggantikan tulisan "Dikerjakan di Minggu 12"
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1060EF), // Biru primary TBCare
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Pasien',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
