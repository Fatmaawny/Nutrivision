import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/views/home/widgets/animated_home_item.dart';
import 'package:mealio/views/home/widgets/calories_plate_card.dart';
import 'package:mealio/views/home/widgets/feature_buttons.dart';
import 'package:mealio/views/home/widgets/healthy_reminder.dart';
import 'package:mealio/views/home/widgets/home_header.dart';
import 'package:mealio/views/home/widgets/nutrition_grid.dart';
import 'package:mealio/views/home/widgets/section_title.dart';
import 'package:mealio/views/water/widgets/water_home_card.dart';

class MobileHomeContent extends StatelessWidget {
  const MobileHomeContent({
    super.key,
    required this.isLoading,
    required this.isLoadingCalories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dailyCalorieGoal,
    required this.userName,
    required this.pageAnimationController,
    required this.onLogout,
    required this.onPageChanged,
    required this.onOpenBmi,
    required this.onRefreshCalories,
    required this.onRefreshUser,
  });

  final bool isLoading;
  final bool isLoadingCalories;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? dailyCalorieGoal;
  final String userName;
  final AnimationController pageAnimationController;
  final VoidCallback onLogout;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenBmi;
  final Future<void> Function() onRefreshCalories;
  final Future<void> Function() onRefreshUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F7F1), Color(0xFFF5F7F0), Color(0xFFF9F3EC)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await onRefreshUser();
            await onRefreshCalories();
          },
          color: AppColors.primaryGreen,
          backgroundColor: Colors.white,
          child: ListView(
            key: const PageStorageKey('mobile-home-list'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 30),
            children: [
              AnimatedHomeItem(
                start: 0.0,
                end: 0.35,
                child: MobileHomeHeader(
                  isLoading: isLoading,
                  userName: userName,
                  onLogout: onLogout,
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 23),
              AnimatedHomeItem(
                start: 0.1,
                end: 0.5,
                child: CaloriesPlateCard(
                  isLoadingCalories: isLoadingCalories,
                  calories: calories,
                  dailyCalorieGoal: dailyCalorieGoal,
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 28),
              AnimatedHomeItem(
                start: 0.2,
                end: 0.6,
                child: SectionTitle(
                  "Today's Nutrition",
                  'Your daily nutrition at a glance',
                  '🥗',
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 15),
              AnimatedHomeItem(
                start: 0.3,
                end: 0.7,
                child: NutritionGrid(
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 29),
              AnimatedHomeItem(
                start: 0.35,
                end: 0.75,
                child: SectionTitle(
                  'Water Intake',
                  'Stay hydrated through the day',
                  '💧',
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 15),
              AnimatedHomeItem(
                start: 0.4,
                end: 0.8,
                child: const WaterHomeCard(),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 29),
              AnimatedHomeItem(
                start: 0.4,
                end: 0.8,
                child: SectionTitle(
                  'Explore Mealio',
                  'Simple tools for your healthy journey',
                  '✨',
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 15),
              AnimatedHomeItem(
                start: 0.5,
                end: 0.9,
                child: FeatureButtons(
                  onPageChanged: onPageChanged,
                  onOpenBmi: onOpenBmi,
                ),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 23),
              AnimatedHomeItem(
                start: 0.6,
                end: 1.0,
                child: HealthyReminder(),
                pageAnimationController: pageAnimationController,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Made with 💚 for a healthier you',
                  style: TextStyle(
                    color: AppColors.secondaryGreenText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
