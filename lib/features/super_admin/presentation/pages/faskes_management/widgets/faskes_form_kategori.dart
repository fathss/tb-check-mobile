import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class FaskesFormKategori extends StatelessWidget {
  final String selectedKategori;
  final ValueChanged<String> onSelect;

  const FaskesFormKategori({
    super.key,
    required this.selectedKategori,
    required this.onSelect,
  });

  Widget _buildKategoriButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBg : AppColors.third,
          border: isActive
              ? Border.all(color: AppColors.primary, width: 0)
              : Border.all(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Faskes',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKategoriButton(
                'Puskesmas',
                selectedKategori == 'Puskesmas',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKategoriButton(
                'Rumah Sakit',
                selectedKategori == 'Rumah Sakit',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
