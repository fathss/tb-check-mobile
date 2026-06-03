import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';

class PatientMedicationLogPage extends StatefulWidget {
  final PatientModel patient;

  const PatientMedicationLogPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientMedicationLogPage> createState() => _PatientMedicationLogPageState();
}

class _PatientMedicationLogPageState extends State<PatientMedicationLogPage> {
  DateTime _selectedDate = DateTime.now();

  // --- DUMMY DATA ---
  // Nanti data ini akan digantikan dari API C#
  final Map<String, List<Map<String, dynamic>>> _dummyMedications = {
    DateFormat('yyyy-MM-dd').format(DateTime.now()): [
      {
        "medicationName": "Rifampisin (150mg)",
        "scheduledTime": "07:00",
        "status": "taken", // taken, pending, missed
        "takenTime": "07:05",
      },
      {
        "medicationName": "Isoniazid (75mg)",
        "scheduledTime": "19:00",
        "status": "pending",
        "takenTime": null,
      }
    ],
    DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1))): [
      {
        "medicationName": "Rifampisin (150mg)",
        "scheduledTime": "07:00",
        "status": "taken",
        "takenTime": "07:30",
      },
      {
        "medicationName": "Ethambutol (400mg)",
        "scheduledTime": "08:00",
        "status": "missed",
        "takenTime": null,
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<Map<String, dynamic>> dailyLogs = _dummyMedications[dateKey] ?? [];

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
                // Circular Chart (Simulasi)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: CircularProgressIndicator(
                        value: 0.92, // 92% Dummy
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade100,
                        color: Colors.green,
                      ),
                    ),
                    const Text('92%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tingkat kepatuhan sangat baik. Pastikan Aan terus menjaga jadwal minum obatnya.', 
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
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
                bool isSelected = DateFormat('yyyy-MM-dd').format(date) == dateKey;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
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
            child: dailyLogs.isEmpty 
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
                    final log = dailyLogs[index];
                    return _buildMedicationCard(log);
                  },
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
    String statusText = isTaken ? 'Diminum ${log['takenTime']} WIB' : (isMissed ? 'Terlewat' : 'Belum Waktunya');

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
                Text(log['medicationName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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