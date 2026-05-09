import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart'; // Pastikan path import benar

class CustomTextField extends StatefulWidget {
  final String label;
  final String? subLabel;
  final String? initialValue;
  final String? hintText;
  final String? footerNote;
  final bool readOnly;
  final bool obscureText;
  final TextEditingController? controller;
  final IconData? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.subLabel,
    this.initialValue,
    this.hintText,
    this.footerNote,
    this.readOnly = false,
    this.obscureText = false,
    this.controller,
    this.suffixIcon = Icons.edit_outlined, // Default icon seperti di gambar
  });
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  bool get _hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _hasFocus ? AppColors.primary : AppColors.textPrimary;
    final suffixColor = _hasFocus ? AppColors.primary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Label & SubLabel
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
            if (widget.subLabel != null) ...[
              const SizedBox(width: 4),
              Text(
                widget.subLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Input Field with animated elevation/shadow on focus
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: widget.readOnly ? const Color(0xFFF5F5F5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            initialValue: widget.initialValue,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.obscureText
                  ? FontWeight.normal
                  : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.transparent,
              suffixIcon: widget.readOnly
                  ? null
                  : Icon(widget.suffixIcon, size: 20, color: suffixColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: _buildBorder(),
              focusedBorder: _buildFocusedBorder(),
            ),
          ),
        ),

        // Footer Note (Opsional)
        if (widget.footerNote != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.footerNote!,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.cardStroke, width: 1.5),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.6),
    );
  }
}
