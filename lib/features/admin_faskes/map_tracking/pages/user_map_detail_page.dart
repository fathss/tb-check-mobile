import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // Import Geocoding
import '../../patients/models/patient_model.dart';
import '../widgets/info_system_card.dart';
import 'user_location_history_page.dart';

class UserMapDetailPage extends StatefulWidget {
  final PatientModel patient;

  const UserMapDetailPage({Key? key, required this.patient}) : super(key: key);

  @override
  State<UserMapDetailPage> createState() => _UserMapDetailPageState();
}

class _UserMapDetailPageState extends State<UserMapDetailPage> {
  String _currentAddress = 'Mencari alamat...';

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
  }

  // --- MENDAPATKAN ALAMAT DARI LATITUDE & LONGITUDE ---
  Future<void> _getAddressFromCoordinates() async {
    if (widget.patient.latitude == null || widget.patient.longitude == null) {
      setState(() => _currentAddress = 'Koordinat lokasi tidak tersedia');
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.patient.latitude!, widget.patient.longitude!);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String addressText = "${place.street}, ${place.subLocality}, ${place.locality}";
        addressText = addressText.replaceAll(', ,', ',').replaceAll(' ,', '').trim();
        
        setState(() => _currentAddress = addressText);
      } else {
        setState(() => _currentAddress = 'Alamat tidak ditemukan');
      }
    } catch (e) {
      // Jika geocoding gagal (misal tidak ada internet), pakai teks bawaan atau lat/lng
      setState(() {
         if (widget.patient.address != null && widget.patient.address!.isNotEmpty) {
             _currentAddress = widget.patient.address!;
         } else {
             _currentAddress = 'Alamat tidak tertera (Lat: ${widget.patient.latitude}, Lng: ${widget.patient.longitude})';
         }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    String initial = widget.patient.fullName.isNotEmpty ? widget.patient.fullName[0].toUpperCase() : 'U';

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
            Text(widget.patient.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStatusChip(widget.patient.status),
            
            const SizedBox(height: 40),
            
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Informasi Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(height: 12),
            
            // KOTAK INFO SEKARANG MENAMPILKAN HASIL GEOCODING
            InfoSystemCard(
              address: _currentAddress,
              phone: 'NIK: ${widget.patient.nik}',
              lastUpdate: _formatDate(widget.patient.diagnosisDate), 
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserLocationHistoryPage(patient: widget.patient),
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

  Widget _buildStatusChip(String rawStatus) {
    String lowerStatus = rawStatus.toLowerCase();
    
    // --- STANDARISASI TEKS BADGE ---
    String displayStatus = rawStatus;
    if (lowerStatus.contains('aktif')) {
      displayStatus = 'Aktif';
    } else if (lowerStatus.contains('drop')) {
      displayStatus = 'Drop-out';
    } else if (lowerStatus.contains('sembuh')) {
      displayStatus = 'Sembuh';
    }

    bool isDrop = lowerStatus.contains('drop');
    bool isSembuh = lowerStatus.contains('sembuh');
    
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
        displayStatus,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}