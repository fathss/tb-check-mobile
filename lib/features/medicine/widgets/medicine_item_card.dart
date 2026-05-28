import 'package:flutter/material.dart';

class MedicineItemCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String schedule;
  final VoidCallback onTap;

  const MedicineItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.schedule,
    required this.onTap,
  });

  @override
  State<MedicineItemCard> createState() => _MedicineItemCardState();
}

class _MedicineItemCardState extends State<MedicineItemCard> {
  bool notificationEnabled = true;

  void toggleNotification() {
    setState(() {
      notificationEnabled = !notificationEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 24),

        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: const Color(0xFFFFE8CC),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Icon(
                Icons.medication,
                color: Colors.orange,
                size: 40,
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

                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.schedule,

                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
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
