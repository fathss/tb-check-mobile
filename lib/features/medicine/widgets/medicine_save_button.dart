import 'package:flutter/material.dart';

class MedicineSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MedicineSaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),

        child: const Text(
          "Save Changes",

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
