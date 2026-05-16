import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class UserMapFilterChips extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const UserMapFilterChips({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _FilterChipItem(
                  label: option,
                  selected: selectedValue == option,
                  onTap: () => onSelected(option),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
