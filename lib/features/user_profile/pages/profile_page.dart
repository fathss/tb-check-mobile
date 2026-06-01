import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';
import 'package:tbcheck_app/features/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tbcheck_app/features/user_profile/pages/edit_profile_page.dart';
import 'package:tbcheck_app/features/user_profile/pages/security_page.dart';
import 'package:tbcheck_app/features/landing/landing_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool isLoading = true;
  String userName = "Memuat...";
  String userEmail = "memuat.data@email.com";
  String initial = "U";
  String userFase = "Memuat data..."; // Variabel baru untuk Rapor Pengobatan

  @override
  void initState() {
    super.initState();
    _loadProfileHeader();
  }

  Future<void> _loadProfileHeader() async {
    final storage = ref.read(authStorageProvider);
    final userId = await storage.getUserId();
    
    if (userId != null) {
      final repo = ref.read(userProfileRepositoryProvider);
      final email = await storage.getEmail(); 
      
      try {
        // Ambil data profil dasar
        final data = await repo.getProfile(userId);
        
        // Ambil data fase dari Home Summary untuk ditampilkan di Kartu Rapor
        final summary = await repo.getHomeSummary(userId);
        
        if (mounted) {
          setState(() {
            userName = data['fullName'] ?? "Pengguna TBCheck";
            if (userName.isNotEmpty) initial = userName[0].toUpperCase();
            if (email != null) userEmail = email;
            
            // Set fase pengobatan (Jika null, berarti belum didaftarkan oleh Faskes)
            userFase = summary.patientId != null ? summary.fase : "Belum Terdaftar di Faskes";
            
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            userName = "Pengguna TBCheck";
            userFase = "Belum Terdaftar di Faskes";
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // HEADER TITLE
              const Text(
                "Profil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // AVATAR
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBg, 
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: isLoading 
                      ? const CircularProgressIndicator()
                      : Text(initial, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 16),

              // NAME & EMAIL
              Text(
                userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),

              // --- KARTU RAPOR PENGOBATAN (MACRO PROGRESS) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Status Pengobatan",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isLoading ? "Menghitung..." : userFase,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // --- PROGRESS BAR 180 HARI ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Perjalanan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                        // TODO: Angka 45 ini sementara, nanti kita ambil selisih hari dari API C# (DiagnosisDate)
                        const Text("45 / 180 Hari", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)), 
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 45 / 180, // Progress statis sementara untuk UI
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // ---------------------------------

              const SizedBox(height: 32),

              // MENU LIST
              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: "Edit Profil Pribadi",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                },
              ),
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: "Keamanan & Kata Sandi",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()));
                },
              ),
              
              const SizedBox(height: 16),
              
              // LOGOUT BUTTON
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: "Keluar",
                isDestructive: true,
                onTap: () async {
                  // 1. Beri nama berbeda pada context dialog (dialogContext) agar tidak bentrok
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Keluar"),
                      content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text("Batal")),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true), 
                          child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final storage = ref.read(authStorageProvider);
                    await storage.clearSession();
                    
                    if (context.mounted) {
                      // 2. Gunakan rootNavigator: true untuk memaksa navigasi dari lapisan paling luar
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LandingPage()), 
                        (route) => false,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET KUSTOM UNTUK MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : AppColors.primaryBg, 
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.redAccent : AppColors.primary, 
            size: 22
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.redAccent : Colors.black87,
            fontSize: 15,
          ),
        ),
        trailing: isDestructive 
          ? null 
          : Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
      ),
    );
  }
}