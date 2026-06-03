import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/dashboard_provider.dart';
import '../../patients/providers/patient_provider.dart'; 

// Import halaman form manual dan form assign
import 'package:tbcheck_app/features/admin_faskes/patients/pages/patient_form_page.dart';
import 'package:tbcheck_app/features/admin_faskes/patients/pages/assign_patient_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
      context.read<PatientProvider>().fetchPatients(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final patientProvider = context.watch<PatientProvider>();
    
    final bool isLoading = dashboardProvider.isLoading || patientProvider.isLoading;
    final bool hasError = dashboardProvider.errorMessage != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.radar, color: Color(0xFF1060EF), size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tim Surveilans', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                const Text('PKM Perak Timur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardProvider>().fetchDashboardData();
          context.read<PatientProvider>().fetchPatients();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600), 
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: isLoading 
              ? _buildFullPageShimmer(key: const ValueKey('shimmer')) 
              : _buildMainContent(context, dashboardProvider, patientProvider, hasError, key: const ValueKey('content')),
        ),
      ),
    );
  }

  // ==========================================
  // KONTEN UTAMA
  // ==========================================
  Widget _buildMainContent(BuildContext context, DashboardProvider dashProvider, PatientProvider patProvider, bool hasError, {Key? key}) {
    if (hasError) {
      return SingleChildScrollView(
        key: key,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
          child: Text('Gagal terhubung: ${dashProvider.errorMessage}', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final total = dashProvider.data?.totalCases ?? 0;
    final aktif = dashProvider.data?.activePatients ?? 0;
    final sembuh = dashProvider.data?.recoveredPatients ?? 0;

    return SingleChildScrollView(
      key: key,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- KOTAK TOTAL KASUS ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1060EF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF1060EF).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Kasus TBC Terdata', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('$total Pasien', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // --- KOTAK PASIEN AKTIF & SEMBUH ---
          Row(
            children: [
              Expanded(child: _buildStatCard('Pasien Aktif', '$aktif', Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Pasien Sembuh', '$sembuh', Colors.green)),
            ],
          ),

          const SizedBox(height: 32),
          const Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // --- TOMBOL AKSI CEPAT DENGAN POP-UP ---
          _buildWideActionCard(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Tambah Pasien Baru',
            subLabel: 'Daftarkan data dan lokasi awal pasien',
            onTap: () {
              // Menampilkan Pop-Up (Bottom Sheet) Pilihan Metode Pendaftaran
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pilih Metode Pendaftaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFE9F0FF), child: Icon(Icons.search, color: Colors.blue)),
                          title: const Text("Tarik Pengguna Terdaftar", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Cari berdasarkan NIK pengguna aplikasi"),
                          onTap: () {
                            Navigator.pop(context); // Tutup bottom sheet
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignPatientPage()));
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFFDE8E8), child: Icon(Icons.edit_document, color: Colors.red)),
                          title: const Text("Input Manual", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Daftarkan pasien yang belum memiliki akun"),
                          onTap: () {
                            Navigator.pop(context); // Tutup bottom sheet
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientFormPage()));
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
              );
            },
          ),
          
          const SizedBox(height: 32),
          const Text('Perlu Tindakan Khusus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // --- KOTAK PERINGATAN KONDISIONAL ---
          _buildAlertBox(patProvider),
        ],
      ),
    );
  }

  Widget _buildAlertBox(PatientProvider patientProvider) {
    final dropOutPatients = patientProvider.patients.where((p) => p.status.toLowerCase().contains('drop')).toList();

    if (dropOutPatients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Semua Pasien Aman', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Seluruh pasien faskes patuh meminum obat.', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final badPatient = dropOutPatients.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.warning_rounded, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${badPatient.fullName} (${badPatient.status})', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Tidak hadir kunjungan wajib faskes.', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: const Text('Lacak', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER BENTUK KARTU
  // ==========================================
  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // KARTU AKSI LEBAR 
  Widget _buildWideActionCard({required IconData icon, required String label, required String subLabel, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 28, color: const Color(0xFF1060EF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // EFEK LOADING SKELETON
  // ==========================================
  Widget _buildFullPageShimmer({Key? key}) {
    return SingleChildScrollView(
      key: key,
      physics: const NeverScrollableScrollPhysics(), 
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 95, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 95, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ],
            ),
            const SizedBox(height: 32),
            Container(width: 120, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))), 
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 32),
            Container(width: 180, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))), 
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 85, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }
}