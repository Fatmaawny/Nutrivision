import 'package:flutter/material.dart';
import 'package:mealio/views/home/widgets/desktop_home_content.dart';
import 'package:mealio/views/home/widgets/mobile_home_content.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return DesktopHomeContent(
            isLoading: isLoading,
            isLoadingCalories: isLoadingCalories,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            dailyCalorieGoal: dailyCalorieGoal,
            userName: userName,
            onLogout: onLogout,
            onPageChanged: onPageChanged,
            onOpenBmi: onOpenBmi,
            onRefreshCalories: onRefreshCalories,
            onRefreshUser: onRefreshUser,
          );
        }

        return MobileHomeContent(
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
      },
    );
  }
}
