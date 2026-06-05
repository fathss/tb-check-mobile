import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'patient_medication_log_page.dart'; 

class PatientDetailPage extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailPage({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logika warna status
    Color statusColor = patient.status.toLowerCase().contains('aktif') 
        ? const Color(0xFF1060EF) 
        : (patient.status.toLowerCase().contains('sembuh') ? Colors.green : Colors.grey);

    // --- LOGIKA FILTER TEKS ALAMAT DUMMY ---
    String displayAddress = patient.address ?? 'Alamat belum diupdate oleh pasien';
    // Jika database mengembalikan teks dummy masa lalu, kita timpa!
    if (displayAddress.toLowerCase().contains('didapatkan dari profil pengguna') || displayAddress.trim().isEmpty) {
      displayAddress = 'Alamat belum diupdate oleh pasien';
    }
    bool isAddressEmpty = displayAddress == 'Alamat belum diupdate oleh pasien';
    // ---------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Pasien', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: () async {
              // 1. Munculkan Pop-up Konfirmasi
              bool? confirm = await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Hapus Pasien?", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text("Apakah Anda yakin ingin menghapus data pasien ini? Data tidak dapat dikembalikan."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false), 
                      child: const Text("Batal", style: TextStyle(color: Colors.grey))
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true), 
                      child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              // 2. Eksekusi Penghapusan jika user menekan "Ya"
              if (confirm == true) {
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menghapus data..."), duration: Duration(seconds: 1))
                );
                
                final success = await context.read<PatientProvider>().deletePatient(patient.id);
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data pasien berhasil dihapus"), backgroundColor: Colors.green)
                  );
                  Navigator.pop(context); 
                } else {
                  final errorMsg = context.read<PatientProvider>().errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMsg ?? "Gagal menghapus data"), backgroundColor: Colors.red)
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION (Profile Card) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        patient.status,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFF1F4F8),
                    child: Text(
                      patient.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIK: ${patient.nik}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Data Medis & Demografi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- INFO CARDS SECTION ---
            _buildInfoCard(
              icon: Icons.calendar_month_rounded,
              title: 'Tanggal Terdiagnosis',
              value: DateFormat('d MMMM yyyy', 'id_ID').format(patient.diagnosisDate),
            ),
            _buildInfoCard(
              icon: Icons.coronavirus_rounded,
              title: 'Tipe Penyakit',
              value: 'TBC ${patient.tbType} Kategori 1', 
            ),
            _buildInfoCard(
              icon: Icons.phone_android_rounded,
              title: 'No. Telepon Aktif',
              value: '0812-3456-7890', 
            ),
            
            // --- KARTU LOKASI ---
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Color(0xFF1060EF), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alamat Domisili & Titik Peta', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        // --- TEKS ALAMAT YANG SUDAH DIFILTER ---
                        Text(
                          displayAddress, 
                          style: TextStyle(
                            color: isAddressEmpty ? Colors.red.shade400 : Colors.black, 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (patient.latitude != null && patient.longitude != null) 
                            ? 'Lat: ${patient.latitude!.toStringAsFixed(4)} | Lng: ${patient.longitude!.toStringAsFixed(4)}'
                            : 'Koordinat belum disinkronkan',
                          style: const TextStyle(color: Color(0xFF1060EF), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- TOMBOL PANTAU OBAT ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => PatientMedicationLogPage(patient: patient))
                  );
                },
                icon: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF1060EF)),
                label: const Text('Pantau Kepatuhan Obat', 
                  style: TextStyle(color: Color(0xFF1060EF), fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9F0FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --- TOMBOL PERBARUI STATUS ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateStatusDialog(context), 
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                label: const Text('Perbarui Status Pasien', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1060EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    String selectedStatus = patient.status == "Aktif" ? "Aktif Dirawat" : patient.status; 
    TextEditingController notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Perbarui Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Pilih Status Baru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 12,
                      children: ['Aktif Dirawat', 'Sembuh', 'Drop-out'].map((status) {
                        bool isSelected = selectedStatus == status;
                        return ChoiceChip(
                          label: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                          selected: isSelected,
                          selectedColor: status == 'Sembuh' ? Colors.green : (status == 'Drop-out' ? Colors.red : const Color(0xFF1060EF)),
                          backgroundColor: Colors.grey.shade100,
                          showCheckmark: false,
                          onSelected: (selected) {
                            setModalState(() {
                              selectedStatus = status;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Catatan Medis (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan perubahan status...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F4F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          setModalState(() => isSubmitting = true);
                          
                          bool success = await context.read<PatientProvider>().updatePatientStatus(
                            patient.id.toString(), 
                            selectedStatus, 
                            notesController.text.isEmpty ? "Diperbarui via sistem" : notesController.text
                          );
                          
                          setModalState(() => isSubmitting = false);
                          
                          if (success) {
                            Navigator.pop(bottomSheetContext); 
                            Navigator.pop(context); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Status berhasil diperbarui!'), backgroundColor: Colors.green),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gagal memperbarui status. Coba lagi.'), backgroundColor: Colors.red),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1060EF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}