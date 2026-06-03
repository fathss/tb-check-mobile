import 'package:flutter/material.dart';
import '../../patients/models/patient_model.dart';

class PatientMapCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const PatientMapCard({Key? key, required this.patient, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDrop = patient.status.toLowerCase().contains('drop');
    bool isSembuh = patient.status.toLowerCase().contains('sembuh');

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
          child: Text(patient.address ?? 'Alamat Belum Terisi', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
        trailing: Container(
          padding
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: bagColor, borderRadius: BorderRadius.circular(20)),
          child: Text(patient.status, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}