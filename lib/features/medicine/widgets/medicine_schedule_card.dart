import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/medicine_provider.dart';

class MedicineScheduleCard extends StatefulWidget {
  final String scheduleId; // Tambahan Baru
  final String patientId;  // Tambahan Baru
  final String time;
  final String medicineName;
  final String description;
  final bool initialDone;

  const MedicineScheduleCard({
    super.key,
    required this.scheduleId,
    required this.patientId,
    required this.time,
    required this.medicineName,
    required this.description,
    required this.initialDone,
  });

  @override
  State<MedicineScheduleCard> createState() => _MedicineScheduleCardState();
}

class _MedicineScheduleCardState extends State<MedicineScheduleCard> {
  late bool isDone;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isDone = widget.initialDone;
  }

  Future<void> toggleStatus() async {
    // Jika sudah selesai atau sedang loading, abaikan klik
    if (isDone || isLoading) return;

    setState(() {
      isLoading = true;
    });

    // Panggil API Konfirmasi ke Backend
    final success = await context.read<MedicineProvider>().confirmConsume(
          widget.scheduleId,
          widget.patientId,
        );

    if (success) {
      setState(() {
        isDone = true;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Obat berhasil dikonfirmasi!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengonfirmasi. Coba lagi."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _getFormattedTime() => widget.time.split(' ').first;

  String _getPeriodLabel() {
    if (widget.time.toLowerCase().contains("pm")) return "Malam";
    return "Pagi";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleStatus,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isDone ? Colors.green : AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getFormattedTime(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPeriodLabel(),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(vertical: 12)),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.medicineName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.description,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Icon(
                          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                          key: ValueKey(isDone),
                          color: isDone ? Colors.green : Colors.grey.shade300,
                          size: 28,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}