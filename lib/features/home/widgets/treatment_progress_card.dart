import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class TreatmentProgressCard extends StatelessWidget {
  final String phase;

  final String description;

  final int currentDose;

  final int totalDose;

  final double progress;

  const TreatmentProgressCard({
    super.key,

    required this.phase,

    required this.description,

    required this.currentDose,

    required this.totalDose,

    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color.fromRGBO(79, 141, 253, 1)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(28),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),

              borderRadius: BorderRadius.circular(30),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.medication_rounded,
                  size: 16,
                  color: Colors.white,
                ),

                const SizedBox(width: 6),

                Text(
                  phase,

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// DESCRIPTION
          Text(
            description,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 14,

              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          /// TOTAL DOSE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "$currentDose / $totalDose Dosis",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "${(progress * 100).toInt()}%",

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 10,

              backgroundColor: Colors.white.withOpacity(0.25),

              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
