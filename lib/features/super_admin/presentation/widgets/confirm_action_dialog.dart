import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

/// Shows a reusable confirmation dialog and returns `true` when the user
/// confirmed the action, `false` when cancelled, or `null` if dismissed.
Future<bool?> showConfirmActionDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Ya',
  String cancelLabel = 'Batal',
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? AppColors.error : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
