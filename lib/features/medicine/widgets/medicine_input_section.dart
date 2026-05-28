import 'package:flutter/material.dart';

class MedicineInputSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isBold;

  const MedicineInputSection({
    super.key,
    required this.title,
    required this.controller,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,

          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,

            color: isBold ? Colors.black : Colors.grey,
          ),

          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const Divider(height: 20),
      ],
    );
  }
}
