import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),
          ],
        ),

        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.success,

        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,

          left: 16,
          right: 16,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),
          ],
        ),

        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.error,

        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,

          left: 16,
          right: 16,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        duration: const Duration(seconds: 2),
      ),
    );
  }
}
