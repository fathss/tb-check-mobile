import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../patients/providers/patient_provider.dart';
import '../../patients/models/patient_model.dart';

class UserLocationHistoryPage extends StatefulWidget {
  final PatientModel patient;

  const UserLocationHistoryPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<UserLocationHistoryPage> createState() => _UserLocationHistoryPageState();
}

class _UserLocationHistoryPageState extends State<UserLocationHistoryPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchLocationHistory(widget.patient.id, _selectedDate);
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // --- FUNGSI BARU: MEMBUKA DIALOG KALENDER DENGAN BATASAN ---
  Future<void> _openDatePicker(DateTime diagnosisDay, DateTime today) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: diagnosisDay, // KUNCI BATAS MINIMUM: Tanggal pasien divonis/terdiagnosa
      lastDate: today,         // KUNCI BATAS MAKSIMUM: Hari ini
      helpText: 'PILIH TANGGAL RIWAYAT',
      builder: (context, child) {
        // Kustomisasi warna tema kalender agar serasi dengan aplikasi TBCare
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1060EF),    // Warna header & tanggal terpilih
              onPrimary: Colors.white,       // Warna teks di atas warna primary
              onSurface: Colors.black87,     // Warna angka tanggal biasa
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1060EF)),
            ),
          ),
          child: child!,
        );
      },
    );

    // Jika admin memilih tanggal baru dan menekan 'OK'
    if (picked != null && !_isSameDay(_selectedDate, picked)) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData(); // Tarik data baru dari API C#
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime diagnosisDay = widget.patient.diagnosisDate;

    bool canGoBack = _selectedDate.isAfter(diagnosisDay) && !_isSameDay(_selectedDate, diagnosisDay);
    bool canGoForward = _selectedDate.isBefore(today) && !_isSameDay(_selectedDate, today);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Riwayat Lengkap', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- KOTAK KALENDER BAR ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Geser Mundur (Kemarin)
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: canGoBack ? Colors.black87 : Colors.grey.shade300),
                    onPressed: canGoBack ? () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      });
                      _loadData();
                    } : null,
                  ),
                  
                  // Tampilan Tanggal - SEKARANG BISA DIKLIK LANGSUNG
                  Expanded(
                    child: InkWell(
                      onTap: () => _openDatePicker(diagnosisDay, today), // Pemicu dialog kalender
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF1060EF), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Geser Maju (Besok)
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, color: canGoForward ? Colors.black87 : Colors.grey.shade300),
                    onPressed: canGoForward ? () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                      });
                      _loadData();
                    } : null,
                  ),
                ],
              ),
            ),
          ),

          // --- TIMELINE AREA ---
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1060EF)));
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)));
                }

                final histories = provider.locationHistories;

                if (histories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada pergerakan lokasi\npada tanggal ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    String formattedTime = DateFormat('HH:mm').format(history.timestamp) + " WIB";

                    return _buildTimelineItem(
                      time: formattedTime,
                      title: history.activityDescription,
                      subtitle: "Koordinat: ${history.latitude}, ${history.longitude}",
                      isFirst: index == 0,
                      isLast: index == histories.length - 1,
                      isLatest: index == 0 && _isSameDay(_selectedDate, DateTime.now()), 
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required bool isLatest,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 2, height: 16, color: isFirst ? Colors.transparent : Colors.grey.shade300),
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: isLatest ? Colors.white : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: isLatest ? Border.all(color: const Color(0xFF1060EF), width: 4) : null,
                ),
              ),
              Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: TextStyle(color: isLatest ? const Color(0xFF1060EF) : Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}