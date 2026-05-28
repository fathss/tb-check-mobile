import 'package:flutter/material.dart';

class InfoSystemCard extends StatelessWidget {
  final String address;
  final String phone;
  final String lastUpdate;

  const InfoSystemCard({
    Key? key,
    required this.address,
    required this.phone,
    required this.lastUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Posisi Terakhir Terdeteksi',
            value: address,
            subValue: 'Update: $lastUpdate',
            valueColor: const Color(0xFF1060EF),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Kontak Pasien',
            value: phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(subValue, style: TextStyle(color: valueColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ]
            ],
          ),
        )
      ],
    );
  }
}