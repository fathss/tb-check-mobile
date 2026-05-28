import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl untuk memformat tanggal
import '../../patients/models/patient_model.dart';
import '../widgets/info_system_card.dart';
import 'user_location_history_page.dart';

class UserMapDetailPage extends StatelessWidget {
  final PatientModel patient;

  const UserMapDetailPage({Key? key, required this.patient}) : super(key: key);

  // Fungsi bantuan untuk memformat tanggal diagnosis menjadi teks yang rapi
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    String initial = patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pengguna',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE9F0FF),
              child: Text(initial,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1060EF))),
            ),
            const SizedBox(height: 16),
            Text(patient.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusChip(patient.status),
            
            const SizedBox(height: 40),
            
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Informasi Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 12),
            
            // KOTAK INFO SEKARANG SEPENUHNYA MENGGUNAKAN DATA ASLI
            InfoSystemCard(
              address: (patient.address == null || patient.address!.isEmpty)
                  ? 'Alamat tidak tertera (Lat: ${patient.latitude}, Lng: ${patient.longitude})'
                  : patient.address!,
              phone: 'NIK: ${patient.nik}', // Karena nomor telepon tidak ada di DB, kita tampilkan NIK sebagai identitas unik pasien
              lastUpdate: _formatDate(patient.diagnosisDate), // Menggunakan tanggal diagnosis asli dari NeonDB
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1060EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  // Kirim data ID pasien ke halaman riwayat agar bisa di-hit ke API PatientHistories
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserLocationHistoryPage(patient: patient),
                    ),
                  );
                },
                icon: const Icon(Icons.route_rounded, color: Colors.white, size: 20),
                label: const Text('Riwayat Lokasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    bool isDrop = status.toLowerCase().contains('drop');
    bool isSembuh = status.toLowerCase().contains('sembuh');
    
    Color bagColor = const Color(0xFFE9F0FF);
    Color textColor = const Color(0xFF1060EF);

    if (isDrop) {
      bagColor = const Color(0xFFFFD6D6);
      textColor = Colors.red.shade700;
    } else if (isSembuh) {
      bagColor = const Color(0xFFE6F7ED);
      textColor = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bagColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}