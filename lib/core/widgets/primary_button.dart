import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 56,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(
            fontSize: 16,

            fontWeight: FontWeight.bold,

            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
