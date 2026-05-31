import 'package:flutter/material.dart';
import '../../../core/widgets/time_helper.dart';

class MedicineScheduleCard extends StatefulWidget {
  final String medicineId;
  final String patientId;
  final String scheduleTime;
  final String time;
  final String medicineName;
  final String description;
  final bool initialDone;
  final Future<void> Function(bool value)? onChanged;

  const MedicineScheduleCard({
    super.key,
    required this.medicineId,
    required this.patientId,
    required this.scheduleTime,
    required this.time,

    required this.medicineName,
    required this.description,
    required this.initialDone,
    required this.onChanged,
  });

  @override
  State<MedicineScheduleCard> createState() => _MedicineScheduleCardState();
}

class _MedicineScheduleCardState extends State<MedicineScheduleCard> {
  late bool isDone;

  @override
  void initState() {
    super.initState();
    isDone = widget.initialDone;
  }

  @override
  void didUpdateWidget(covariant MedicineScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialDone != widget.initialDone) {
      setState(() {
        isDone = widget.initialDone;
      });
    }
  }

  Future<void> toggleStatus() async {
    final newValue = !isDone;

    if (widget.onChanged != null) {
      await widget.onChanged!(newValue);
    }

    setState(() {
      isDone = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleStatus,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF2FFF4) : const Color(0xFFF7F8FA),

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isDone ? Colors.green.shade200 : Colors.transparent,
          ),
        ),

        child: Row(
          children: [
            Text(
              "${widget.time} ${TimeHelper.getPeriodLabel(widget.time)}",

              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            const SizedBox(width: 16),

            Container(width: 1, height: 70, color: Colors.grey.shade300),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.medicineName,

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,

                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.description,

                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              child: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,

                key: ValueKey(isDone),

                color: isDone ? Colors.green : Colors.grey,

                size: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
