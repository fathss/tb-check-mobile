import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class MedicineCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback? onConfirm;

  const MedicineCard({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(width: 12),

              Container(height: 40, width: 1, color: Colors.grey),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
              ),
            ],
          ),

          if (!isDone) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: onConfirm,
                child: const Text(
                  "Konfirmasi Minum",
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
