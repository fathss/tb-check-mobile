import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart'; // Pastikan path import benar

class CustomTextField extends StatelessWidget {
  final String label;
  final String? subLabel;
  final String? initialValue;
  final String? hintText;
  final String? footerNote;
  final bool readOnly;
  final bool obscureText;
  final TextEditingController? controller;
  final IconData? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.subLabel,
    this.initialValue,
    this.hintText,
    this.footerNote,
    this.readOnly = false,
    this.obscureText = false,
    this.controller,
    this.suffixIcon = Icons.edit_outlined, // Default icon seperti di gambar
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Label & SubLabel
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(width: 4),
              Text(
                subLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Input Field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: obscureText ? FontWeight.normal : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
            suffixIcon: readOnly
                ? null
                : Icon(suffixIcon, size: 20, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: _buildBorder(),
            focusedBorder: _buildBorder(),
          ),
        ),

        // Footer Note (Opsional)
        if (footerNote != null) ...[
          const SizedBox(height: 6),
          Text(
            footerNote!,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cardStroke, width: 1.5),
    );
  }
}
