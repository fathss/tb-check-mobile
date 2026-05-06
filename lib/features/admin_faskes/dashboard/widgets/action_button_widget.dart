import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget{
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButtonWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)
          ),
          child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 28,),
            const SizedBox(height: 8,),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            )
          ],
        )
        ),
      );
  }
}