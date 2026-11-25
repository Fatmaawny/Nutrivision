import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/views/home/widgets/feature_card.dart';

class FeatureButtons extends StatelessWidget {
  const FeatureButtons({
    super.key,
    required this.onPageChanged,
    required this.onOpenBmi,
  });

  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenBmi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Meal Tracker',
            subtitle: 'Track your meals',
            onTap: () => onPageChanged(1),
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FeatureCard(
            icon: Icons.monitor_weight_rounded,
            title: 'BMI Calculator',
            subtitle: 'Check your BMI',
            onTap: onOpenBmi,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}
