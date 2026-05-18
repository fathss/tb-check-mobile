import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/widgets/date_field.dart';
import 'package:tbcheck_app/features/admin_faskes/patient_location_history/widgets/patient_timeline_item.dart';

import 'package:tbcheck_app/features/admin_faskes/patient_location_history/models/patient_timeline_model.dart';

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
    // 1. FILTER DATA BERDASARKAN TANGGAL YANG DIPILIH
    // Membandingkan tahun, bulan, dan hari saja (mengabaikan jam/menit jika ada)
    final filteredTimelineData = mockPatientTimelineData.where((item) {
      return item.tanggal.year == _selectedDate.year &&
          item.tanggal.month == _selectedDate.month &&
          item.tanggal.day == _selectedDate.day;
    }).toList();

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

              // 2. TAMPILKAN TIMELINE ATAU EMTPY STATE JIKA DATA TIDAK DITEMUKAN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: filteredTimelineData.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada riwayat lokasi pada tanggal ini.",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          // Menggunakan data hasil filter
                          itemCount: filteredTimelineData.length,
                          itemBuilder: (context, index) {
                            final item = filteredTimelineData[index];

                            // Penentuan item pertama dan terakhir disesuaikan dengan list yang sudah difilter
                            final bool isFirst = index == 0;
                            final bool isLast =
                                index == filteredTimelineData.length - 1;

                            return PatientTimelineItem(
                              time: "${item.waktu} WIB",
                              title: item.lokasi,
                              subtitle: "${item.lat}, ${item.lng}",
                              isFirst: isFirst,
                              isLast: isLast,
                            );
                          },
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
