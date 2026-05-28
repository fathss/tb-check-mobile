import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class ProfileInputSection extends StatelessWidget {
  final String title;

  final TextEditingController controller;

  final bool isBold;

  final bool obscureText;

  final IconData? suffixIcon;

  final VoidCallback? onSuffixTap;
  final bool readOnly;

  const ProfileInputSection({
    super.key,
    required this.title,
    required this.controller,

    this.isBold = false,

    this.obscureText = false,

    this.suffixIcon,

    this.onSuffixTap,
    this.readOnly = false,
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

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,

                obscureText: obscureText,
                readOnly: readOnly,

                style: TextStyle(
                  fontSize: 16,

                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,

                  color: isBold ? Colors.black : AppColors.textSecondary,
                ),

                decoration: const InputDecoration(
                  border: InputBorder.none,

                  isDense: true,

                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            if (suffixIcon != null)
              GestureDetector(
                onTap: onSuffixTap,

                child: Icon(suffixIcon, color: AppColors.textSecondary),
              ),
          ],
        ),

        const Divider(height: 14),
      ],
    );
  }
}
