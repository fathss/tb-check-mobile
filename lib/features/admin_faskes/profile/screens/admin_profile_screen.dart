import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/faskes_profile_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final TextEditingController _contactController = TextEditingController();

  // Status untuk mengontrol apakah sedang mode edit atau mode lihat
  bool _isEditing = false;
  bool _isSaving = false;

  // Variabel terpisah untuk jam buka dan tutup
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
      
      // Memecah format "08:00 - 14:00 WIB" menjadi 2 variabel
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

  // Fungsi untuk memunculkan jam digital HP
  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    // Ubah string "08:00" menjadi objek TimeOfDay agar bisa dibaca picker
    List<String> timeParts = (isOpeningTime ? _openTime : _closeTime).split(':');
    TimeOfDay initialTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 8, 
      minute: int.tryParse(timeParts[1]) ?? 0
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        // Memaksa format 24 jam (hilangkan AM/PM)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format angka di bawah 10 agar ada angka 0 di depannya (misal: 08:05)
        String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isOpeningTime) {
          _openTime = formattedTime;
        } else {
          _closeTime = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Institusi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<FaskesProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                // --- 1. KARTU HEADER (NAMA & TIPE) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.domain_rounded, size: 32, color: Color(0xFF1060EF)),
                      ),
                      const SizedBox(height: 16),
                      Text(profile?.name ?? 'Memuat...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(profile?.type ?? 'Memuat...', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1060EF))),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // --- 2. WILAYAH JANGKAUAN (SELALU READ-ONLY) ---
                const Text('Wilayah Jangkauan Pemantauan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF1060EF), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(profile?.address ?? '-', style: const TextStyle(color: Color(0xFF1060EF), fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('Diatur oleh Super Admin.', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                
                const SizedBox(height: 24),
                
                // --- 3. INPUT JAM OPERASIONAL ---
                const Text('Jam Operasional Layanan TBC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                
                // Jika sedang diedit, muncul 2 tombol jam. Jika tidak, muncul 1 baris teks.
                _isEditing 
                  ? Row(
                      children: [
                        Expanded(child: _buildTimePickerBox("Buka", _openTime, () => _selectTime(context, true))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("-", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: _buildTimePickerBox("Tutup", _closeTime, () => _selectTime(context, false))),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Text("$_openTime - $_closeTime WIB", style: const TextStyle(fontSize: 16)),
                    ),

                const SizedBox(height: 16),
                
                // --- 4. INPUT NOMOR DARURAT ---
                const Text('Nomor Darurat / Call Center', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactController,
                  enabled: _isEditing, // Hanya bisa diketik jika mode edit aktif
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1060EF), width: 1.5)),
                    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
                
                const SizedBox(height: 32),

                // --- 5. TOMBOL AKSI UTAMA ---
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _isEditing 
                      // TOMBOL SIMPAN (Mode Edit Aktif)
                      ? Row(
                          children: [
                            // Tombol Batal
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: const BorderSide(color: Colors.red),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _populateFields(); // Kembalikan data seperti semula jika batal
                                  });
                                },
                                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tombol Simpan
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1060EF),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: _isSaving ? null : () async {
                                  setState(() => _isSaving = true);
                                  
                                  final updatedData = {
                                    "name": profile?.name ?? "",
                                    "type": profile?.type ?? "",
                                    "address": profile?.address ?? "",
                                    "operatingHours": "$_openTime - $_closeTime WIB", // Menggabungkan format jam
                                    "emergencyContact": _contactController.text,
                                    "latitude": profile?.latitude ?? 0.0, 
                                    "longitude": profile?.longitude ?? 0.0,
                                  };

                                  final success = await provider.updateProfile(updatedData);
                                  
                                  setState(() {
                                    _isSaving = false;
                                    if (success) _isEditing = false; // Matikan mode edit jika sukses
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
                        )
                      // TOMBOL UBAH PROFIL (Mode Baca)
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1060EF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                          label: const Text('Ubah Profil Faskes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Bantuan: Kotak Jam yang bisa diklik
  Widget _buildTimePickerBox(String label, String timeValue, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF1060EF).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
}