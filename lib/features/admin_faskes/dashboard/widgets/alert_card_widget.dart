import 'package:flutter/material.dart';

class AlertCardWidget extends StatelessWidget {
  final String patientName;
  final String message;
  final VoidCallback onTrack;

  const AlertCardWidget({
    Key? key,
    required this.patientName,
    required this.message,
    required this.onTrack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$patientName (Drop-out)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
            ),
            onPressed: onTrack,
            child: const Text('Lacak'),
          )
        ],
      ),
    );
  }
}