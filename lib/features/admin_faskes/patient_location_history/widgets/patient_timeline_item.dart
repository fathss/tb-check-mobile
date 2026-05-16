import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class PatientTimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const PatientTimelineItem({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN UTAMA: IntrinsicHeight diletakkan paling luar membungkus Row
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEKTOR KIRI: INDIKATOR GARIS DAN MODUL BULATAN ---
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // Bulatan Indikator
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? const Color(0xFF1976D2)
                          : Colors.grey.shade400,
                      width: 4,
                    ),
                  ),
                ),

                // Garis bawah (Dashed Line)
                Expanded(
                  flex: 3,
                  child: isLast
                      ? const SizedBox()
                      : _DashedLine(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- SEKTOR KANAN: KONTEN TEKS ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
              ), // Mengatur jarak vertikal antar item
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFirst ? AppColors.primary : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _DashedLine dan _DashedLinePainter milik Anda di bawah tetap sama, tidak perlu diubah.
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(2, double.infinity),
      painter: _DashedLinePainter(color: color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
