import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class CustomSearchField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomSearchField({
    Key? key,
    this.hintText = 'Cari Puskesmas atau RSUD...',
    this.controller,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    // keep focus on field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 22.0,
            ),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                    onPressed: _clear,
                  ),
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
