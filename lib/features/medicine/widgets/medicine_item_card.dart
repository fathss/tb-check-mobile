import 'package:flutter/material.dart';

class MedicineItemCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String schedule;
  final int imageIndex; // Tambahan untuk mengatur warna dinamis
  final VoidCallback onTap;

  const MedicineItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.schedule,
    required this.imageIndex,
    required this.onTap,
  });

  @override
  State<MedicineItemCard> createState() => _MedicineItemCardState();
}

class _MedicineItemCardState extends State<MedicineItemCard> {
  bool notificationEnabled = true;

  final List<IconData> medicineIcons = [
    Icons.medication,
    Icons.medical_information,
    Icons.receipt_long,
    Icons.trip_origin,
  ];

  final List<Color> iconBgColors = [
    const Color(0xFFFFF0D4),
    const Color(0xFFFFE5F0),
    const Color(0xFFE0FAFA),
    const Color(0xFFE8EBFF),
  ];

  final List<Color> iconColors = [
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFF673AB7),
  ];

  void toggleNotification() {
    setState(() {
      notificationEnabled = !notificationEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Memastikan index tidak out of bounds
    final int safeIndex = widget.imageIndex >= 0 && widget.imageIndex < medicineIcons.length 
        ? widget.imageIndex 
        : 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          children: [
            Container(
              width: 64, // Sedikit diperkecil agar proporsional seperti Figma
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColors[safeIndex],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                medicineIcons[safeIndex],
                color: iconColors[safeIndex],
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.schedule,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: toggleNotification,
                  child: Icon(
                    notificationEnabled
                        ? Icons.notifications
                        : Icons.notifications_off,
                    color: notificationEnabled ? Colors.grey : Colors.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}