import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class FaskesFormLocationField extends StatelessWidget {
  final LatLng? selectedCoordinate;
  final VoidCallback onTap;

  const FaskesFormLocationField({
    super.key,
    required this.selectedCoordinate,
    required this.onTap,
  });

  String _formatCoordinate(LatLng coordinate) {
    return '${coordinate.latitude.toStringAsFixed(6)}, ${coordinate.longitude.toStringAsFixed(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final coordinateText = selectedCoordinate != null
        ? _formatCoordinate(selectedCoordinate!)
        : 'Pilih titik lokasi di Peta...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Titik Lokasi',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.third,
              border: Border.all(color: AppColors.cardStroke),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coordinateText,
                    style: TextStyle(
                      fontSize: 13,
                      color: selectedCoordinate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
