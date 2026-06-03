import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/faskes_profile_provider.dart';
// IMPORT INI PENTING UNTUK FITUR LOGOUT
import '../../../../features/auth/data/datasources/auth_storage.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _contactController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  String _openTime = "08:00";
  String _closeTime = "14:00";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaskesProfileProvider>().fetchProfile().then((_) {
        _populateFields();
      });
    });
  }

  void _populateFields() {
    final profile = context.read<FaskesProfileProvider>().profile;
    if (profile != null) {
      _contactController.text = profile.emergencyContact;
      
      String opHours = profile.operatingHours;
      if (opHours.contains('-')) {
        var parts = opHours.replaceAll(' WIB', '').split('-');
        if (parts.length == 2) {
          _openTime = parts[0].trim();
          _closeTime = parts[1].trim();
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    List<String> timeParts = (isOpeningTime ? _openTime : _closeTime).split(':');
    TimeOfDay initialTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 8, 
      minute: int.tryParse(timeParts[1]) ?? 0
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isOpeningTime) {
          _openTime = formattedTime;
        } else {
          _closeTime = formattedTime;
        }
      });
    }
  }

  // =======================================================
  // FUNGSI LOGOUT DENGAN POP-UP KONFIRMASI
  // =======================================================
  Future<void> _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari sesi Admin ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Hapus data sesi di memori lokal
      final storage = AuthStorage();
      await storage.clearSession();
      
      if (!mounted) return;
      // Tendang user kembali ke halaman login dan hapus tumpukan riwayat halaman
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu sangat muda yang premium
      appBar: AppBar(
        title: const Text('Profil Institusi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Icon Log out kecil di atas untuk alternatif
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: Consumer<FaskesProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1060EF)));
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)));
          }

          final profile = provider.profile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. KARTU HEADER ESTETIK ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F0FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF1060EF).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
                          ]
                        ),
                        child: const Icon(Icons.local_hospital_rounded, size: 40, color: Color(0xFF1060EF)),
                      ),
                      const SizedBox(height: 20),
                      Text(profile?.name ?? 'Memuat...', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(profile?.type ?? 'Memuat...', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1060EF))),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('Informasi Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                
                // --- 2. WILAYAH JANGKAUAN (READ-ONLY) ---
                _buildInfoCard(
                  icon: Icons.map_rounded,
                  title: 'Wilayah Jangkauan (Pusat)',
                  value: profile?.address ?? 'Alamat tidak tersedia',
                ),

                // --- 3. JAM OPERASIONAL ---
                _isEditing 
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jam Operasional Layanan TBC', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildTimePickerBox("Buka", _openTime, () => _selectTime(context, true))),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("-", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                              Expanded(child: _buildTimePickerBox("Tutup", _closeTime, () => _selectTime(context, false))),
                            ],
                          ),
                        ],
                      ),
                    )
                  : _buildInfoCard(
                      icon: Icons.access_time_filled_rounded,
                      title: 'Jam Operasional Layanan TBC',
                      value: "$_openTime - $_closeTime WIB",
                    ),

                // --- 4. NOMOR DARURAT ---
                _isEditing 
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nomor Darurat / Call Center', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _contactController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.phone_rounded, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1060EF), width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildInfoCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Nomor Darurat / Call Center',
                      value: _contactController.text.isNotEmpty ? _contactController.text : "Belum diatur",
                    ),
                
                const SizedBox(height: 16),

                // --- 5. TOMBOL AKSI UTAMA ---
                _isEditing 
                    // TOMBOL SIMPAN & BATAL (Mode Edit Aktif)
                    ? SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _populateFields(); // Kembalikan ke asal jika batal
                                  });
                                },
                                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1060EF),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _isSaving ? null : () async {
                                  setState(() => _isSaving = true);
                                  
                                  final updatedData = {
                                    "name": profile?.name ?? "",
                                    "type": profile?.type ?? "",
                                    "address": profile?.address ?? "",
                                    "operatingHours": "$_openTime - $_closeTime WIB",
                                    "emergencyContact": _contactController.text,
                                    "latitude": profile?.latitude ?? 0.0, 
                                    "longitude": profile?.longitude ?? 0.0,
                                  };

                                  final success = await provider.updateProfile(updatedData);
                                  
                                  setState(() {
                                    _isSaving = false;
                                    if (success) _isEditing = false; 
                                  });

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil Faskes diperbarui!'), backgroundColor: Colors.green));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil.'), backgroundColor: Colors.red));
                                  }
                                },
                                child: _isSaving 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      )
                    // TOMBOL UBAH PROFIL & LOGOUT (Mode Baca)
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1060EF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: () => setState(() => _isEditing = true),
                              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                              label: const Text('Ubah Profil Institusi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _handleLogout,
                              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                              label: const Text('Keluar dari Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Bantuan: Kotak Jam yang bisa diklik (Hanya muncul saat mode edit)
  Widget _buildTimePickerBox(String label, String timeValue, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timeValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF1060EF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Info Card Estetik ala Patient Detail (Untuk mode baca)
  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1060EF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}