import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tbcheck_app/core/theme/app_colors.dart';

class DateField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateField({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  void _changeDate(int days) {
    final newDate = selectedDate.add(Duration(days: days));
    onDateChanged(newDate); // Lempar tanggal baru ke halaman utama
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.third,
          borderRadius: BorderRadius.circular(24.0), // Melengkung di sudut luar
          border: Border.all(color: AppColors.cardStroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Panah Kiri
            _buildArrowButton(
              icon: Icons.chevron_left,
              onTap: () => _changeDate(-1),
            ),

            // Indikator tanggal
            Expanded(
              child: InkWell(
                onTap: () => _pickDate(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month, // Icon kalender biru
                      color: AppColors.primary,
                      size: 24.0,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol panah kanan
            _buildArrowButton(
              icon: Icons.chevron_right,
              onTap: () => _changeDate(1),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildArrowButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16.0,
        ), // Sudut membulat tombol panah
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4), // Efek shadow drop soft di bawah tombol
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xff1e293b), size: 24.0),
    ),
  );
}
