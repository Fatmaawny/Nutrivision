import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, this.subtitle, this.emoji, {super.key});

  final String title;
  final String subtitle;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title $emoji',
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondaryGreenText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
