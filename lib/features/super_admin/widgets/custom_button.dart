import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    );

    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: foregroundColor),
            label: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
            style: buttonStyle,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          );

    if (width == null) {
      return button;
    }

    return SizedBox(width: width, child: button);
  }
}
