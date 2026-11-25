import 'package:flutter/material.dart';
import 'package:mealio/data/services/meal_data_service.dart';
import 'package:mealio/views/home/widgets/home_content.dart';
import 'package:mealio/views/meals/meals_screen.dart';
import 'package:mealio/views/meals/saved_meals_screen.dart';
import 'package:mealio/views/profile/profile_screen.dart';
import 'package:mealio/views/tips/tips_screen.dart';
import 'package:mealio/views/weekly_progress/weekly_progress.dart';

class HomeSelectedPage extends StatelessWidget {
  const HomeSelectedPage({
    super.key,
    required this.isLoading,
    required this.isLoadingCalories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dailyCalorieGoal,
    required this.userName,
    required this.selectedIndex,
    required this.mealService,
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
  final int selectedIndex;
  final MealDataService mealService;
  final AnimationController pageAnimationController;
  final VoidCallback onLogout;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenBmi;
  final Future<void> Function() onRefreshCalories;
  final Future<void> Function() onRefreshUser;

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return HomeContent(
          isLoading: isLoading,
          isLoadingCalories: isLoadingCalories,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          dailyCalorieGoal: dailyCalorieGoal,
          userName: userName,
          pageAnimationController: pageAnimationController,
          onLogout: onLogout,
          onPageChanged: onPageChanged,
          onOpenBmi: onOpenBmi,
          onRefreshCalories: onRefreshCalories,
          onRefreshUser: onRefreshUser,
        );

      case 1:
        return MealsScreen();

      case 2:
        return SavedMealsScreen(mealService: mealService);

      case 3:
        return TipsScreen();

      case 4:
        return  WeeklyProgress();

      case 5:
        return const ProfileScreen();

      default:
        return HomeContent(
          isLoading: isLoading,
          isLoadingCalories: isLoadingCalories,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          dailyCalorieGoal: dailyCalorieGoal,
          userName: userName,
          pageAnimationController: pageAnimationController,
          onLogout: onLogout,
          onPageChanged: onPageChanged,
          onOpenBmi: onOpenBmi,
          onRefreshCalories: onRefreshCalories,
          onRefreshUser: onRefreshUser,
        );
    }
  }
}
