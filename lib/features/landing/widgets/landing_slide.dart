import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';

class LandingSlide extends StatelessWidget {
  final String imageUrl;
  final String title;

  const LandingSlide({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.image_not_supported, size: 128),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
