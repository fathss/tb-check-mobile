import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class PatientDetailPage extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailPage({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logika warna status
    Color statusColor = patient.status.toLowerCase().contains('aktif') 
        ? const Color(0xFF1060EF) 
        : (patient.status.toLowerCase().contains('sembuh') ? Colors.green : Colors.grey);

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
                  // Status Badge (Pojok Kanan Atas dalam Card)
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
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFF1F4F8),
                    child: Text(
                      patient.fullName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nama & NIK
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
                        Text(patient.address ?? 'Alamat tidak tersedia', style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        // Menampilkan koordinat GPS
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

            const SizedBox(height: 32),

            // --- TOMBOL PERBARUI ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateStatusDialog(context), // Memanggil fungsi pop-up estetik
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

  // Widget Helper untuk membuat kartu informasi
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
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1060EF), size: 24),
          ),
          const SizedBox(width: 16),
          // Text Content
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

  // ==========================================
  // FUNGSI POP-UP PERBARUI STATUS (ESTETIK)
  // ==========================================
  void _showUpdateStatusDialog(BuildContext context) {
    // Menyimpan status lokal hanya untuk pop-up ini
    String selectedStatus = patient.status == "Aktif" ? "Aktif Dirawat" : patient.status; 
    TextEditingController notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar pop-up ikut naik saat keyboard muncul
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Menghindari tertutup keyboard
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
                    // Header Pop-up
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
                    
                    // Pilihan Status (Wrap agar rapi jika kepanjangan)
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
                    
                    // Input Catatan
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
                    
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          // Mulai loading di dalam pop-up
                          setModalState(() => isSubmitting = true);
                          
                          // Eksekusi fungsi ke backend C#
                          bool success = await context.read<PatientProvider>().updatePatientStatus(
                            patient.id.toString(), 
                            selectedStatus, 
                            notesController.text.isEmpty ? "Diperbarui via sistem" : notesController.text
                          );
                          
                          setModalState(() => isSubmitting = false);
                          
                          if (success) {
                            Navigator.pop(bottomSheetContext); // Tutup pop-up
                            Navigator.pop(context); // Kembali ke list utama agar me-refresh data otomatis
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