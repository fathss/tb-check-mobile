import 'package:flutter/material.dart';
import '../../patients/models/patient_model.dart';

class PatientMapCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const PatientMapCard({Key? key, required this.patient, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String lowerStatus = patient.status.toLowerCase();

    // --- STANDARISASI TEKS BADGE ---
    String displayStatus = patient.status;
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDrop ? const Color(0xFFFFEBEB) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDrop ? Colors.red.shade100 : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            patient.address != null && patient.address!.isNotEmpty 
                ? patient.address! 
                : 'Alamat belum diupdate oleh pasien', 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: bagColor, borderRadius: BorderRadius.circular(20)),
          child: Text(
            displayStatus, // <--- SEKARANG MENGGUNAKAN TEKS YANG SUDAH DISTANDARISASI
            style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}