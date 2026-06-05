import 'package:flutter/material.dart';

class MedicineDaySelector extends StatelessWidget {
  final List<bool> activeDays;
  final Function(int) onToggle;

  const MedicineDaySelector({
    super.key,
    required this.activeDays,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: List.generate(
            days.length,
            (index) => GestureDetector(
              onTap: () => onToggle(index),

              child: Column(
                children: [
                  Text(
                    days[index],

                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),

                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: activeDays[index]
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE5E7EB),

                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
