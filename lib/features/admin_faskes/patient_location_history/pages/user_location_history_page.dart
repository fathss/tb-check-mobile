import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/widgets/date_field.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/widgets/patient_timeline_item.dart';

class UserLocationHistoryPage extends StatefulWidget {
  final String pageTitle;

  const UserLocationHistoryPage({required this.pageTitle, super.key});

  @override
  State<UserLocationHistoryPage> createState() =>
      _UserLocationHistoryPageState();
}

class _UserLocationHistoryPageState extends State<UserLocationHistoryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Date Field
          Column(
            children: [
              DateField(
                selectedDate: _selectedDate,
                onDateChanged: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Patient Timeline
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListView(
                    children: const [
                      PatientTimelineItem(
                        time: "14:45 WIB",
                        title: "Tiba di Rumah (Domisili)",
                        subtitle: "Jl. Raya ITS, Sukolilo, Surabaya.",
                        isFirst:
                            true, // Item pertama: Garis atas otomatis hilang
                      ),
                      PatientTimelineItem(
                        time: "14:15 WIB",
                        title: "Dalam Perjalanan Pulang",
                        subtitle: "Melewati Jl. Menur Pumpungan, Surabaya.",
                      ),
                      PatientTimelineItem(
                        time: "13:00 WIB",
                        title: "Apotek Puskesmas (Ambil Obat)",
                        subtitle:
                            "Pengambilan obat anti-tuberculosis (OAT) bulan ke-2.",
                      ),
                      PatientTimelineItem(
                        time: "12:30 WIB",
                        title: "Meninggalkan Ruang Konsultasi Dokter",
                        subtitle: "Puskesmas Sukolilo, Surabaya.",
                      ),
                      PatientTimelineItem(
                        time: "10:00 WIB",
                        title: "Pemeriksaan Laboratorium",
                        subtitle: "Pengambilan sampel dahak selesai dilakukan.",
                      ),
                      PatientTimelineItem(
                        time: "09:30 WIB",
                        title: "Konsultasi Poli Paru",
                        subtitle: "Pemeriksaan fisik oleh dr. Spesialis Paru.",
                      ),
                      PatientTimelineItem(
                        time: "09:15 WIB",
                        title: "Check-in Lokasi Faskes",
                        subtitle: "Puskesmas Sukolilo, Surabaya.",
                      ),
                      PatientTimelineItem(
                        time: "08:45 WIB",
                        title: "Meninggalkan Rumah (Domisili)",
                        subtitle:
                            "Perjalanan menuju faskes menggunakan kendaraan roda dua.",
                        isLast:
                            true, // Item terakhir: Garis bawah otomatis hilang
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
