import 'package:flutter/material.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/alert_card_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.radar, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tim Surveilans', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const Text('PKM Perak Timur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.blue]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Kasus TBC Terdata', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('145 Pasien', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: StatCardWidget(title: 'Pasien Aktif', value: '45', color: Colors.orange)),
                SizedBox(width: 16),
                Expanded(child: StatCardWidget(title: 'Pasien Sembuh', value: '100', color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ActionButtonWidget(icon: Icons.person_add, label: 'Data Pasien', onTap: () {})),
                const SizedBox(width: 16),
                Expanded(child: ActionButtonWidget(icon: Icons.map, label: 'Peta Sebaran', onTap: () {})),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Perlu Tindakan Khusus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AlertCardWidget(
              patientName: 'Supriyadi',
              message: 'Tidak hadir kunjungan wajib > 2 minggu.',
              onTrack: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}