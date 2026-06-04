import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';

class PatientMedicationLogPage extends StatefulWidget {
  final PatientModel patient;

  const PatientMedicationLogPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientMedicationLogPage> createState() => _PatientMedicationLogPageState();
}

class _PatientMedicationLogPageState extends State<PatientMedicationLogPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Mengambil data obat saat halaman pertama kali dibuka berdasarkan tanggal hari ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLogsForSelectedDate();
    });
  }

  void _fetchLogsForSelectedDate() {
    // Memanggil API melalui provider untuk mengambil data jadwal obat sesuai tanggal
    context.read<PatientProvider>().fetchMedicationLogs(
      widget.patient.id.toString(), 
      _selectedDate
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan data di Provider
    final provider = context.watch<PatientProvider>();
    final isLoading = provider.isLoading;
    final dailyLogs = provider.medicationLogs;
    final complianceRate = provider.complianceRate;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kepatuhan Minum Obat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- 1. KARTU SKOR (HEADER) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Circular Chart (Sudah Dinamis)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: CircularProgressIndicator(
                        value: complianceRate, 
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade100,
                        // Berubah warna jika kepatuhan di bawah 50%
                        color: complianceRate < 0.5 ? Colors.red : (complianceRate < 0.8 ? Colors.orange : Colors.green),
                      ),
                    ),
                    Text('${(complianceRate * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // Teks "Aan" sudah diganti jadi dinamis!
                      Text(
                        'Pastikan ${widget.patient.fullName} terus menjaga jadwal minum obatnya agar pengobatan berjalan lancar.', 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // --- 2. KALENDER GESER (7 HARI TERAKHIR) ---
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true, // Urutan dari hari ini memundur ke belakang
              itemCount: 7,
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().subtract(Duration(days: index));
                bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _fetchLogsForSelectedDate(); // Fetch ulang data ke C# saat ganti hari
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.only(left: 8, right: index == 0 ? 16 : 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1060EF) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E', 'id_ID').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(date.day.toString(), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // --- 3. TIMELINE OBAT ---
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : (dailyLogs.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Tidak ada jadwal obat\nuntuk tanggal ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dailyLogs.length,
                      itemBuilder: (context, index) {
                        // Cast data dinamis dari map
                        final log = dailyLogs[index] as Map<String, dynamic>;
                        return _buildMedicationCard(log);
                      },
                    )
                ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> log) {
    bool isTaken = log['status'] == 'taken';
    bool isMissed = log['status'] == 'missed';
    
    Color statusColor = isTaken ? Colors.green : (isMissed ? Colors.red : Colors.orange);
    IconData statusIcon = isTaken ? Icons.check_circle_rounded : (isMissed ? Icons.cancel_rounded : Icons.schedule_rounded);
    
    // Teks dimodifikasi agar tahan terhadap tipe null
    String statusText = 'Belum Waktunya';
    if (isTaken) {
      statusText = 'Diminum ${log['takenTime']} WIB';
    } else if (isMissed) {
      statusText = 'Terlewat';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Ikon Pil
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication_rounded, color: Color(0xFF1060EF)),
          ),
          const SizedBox(width: 16),
          // Info Obat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['medicationName'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Jadwal: ${log['scheduledTime']} WIB', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}