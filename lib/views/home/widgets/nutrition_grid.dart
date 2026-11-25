import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/views/home/widgets/nutrition_card.dart';

class NutritionGrid extends StatelessWidget {
  const NutritionGrid({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        const spacing = 12.0;

        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        final aspectRatio = constraints.maxWidth >= 900 ? 2.05 : 1.75;

        final itemHeight = itemWidth / aspectRatio;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: NutritionCard(
                title: 'Protein',
                value: protein.toStringAsFixed(0),
                unit: 'g',
                emoji: '🥚',
                color: AppColors.terracotta,
              ),
            ),
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: NutritionCard(
                title: 'Carbs',
                value: carbs.toStringAsFixed(0),
                unit: 'g',
                emoji: '🌾',
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: NutritionCard(
                title: 'Fat',
                value: fat.toStringAsFixed(0),
                unit: 'g',
                emoji: '🥑',
                color: AppColors.gold,
              ),
            ),
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: NutritionCard(
                title: 'Calories',
                value: calories.toStringAsFixed(0),
                unit: 'kcal',
                emoji: '🔥',
                color: AppColors.secondaryGreenText,
              ),
            ),
          ],
        );
      },
    );
  }
}
