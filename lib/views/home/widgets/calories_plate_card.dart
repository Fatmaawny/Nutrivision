import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class CaloriesPlateCard extends StatelessWidget {
  const CaloriesPlateCard({
    super.key,
    this.desktop = false,
    required this.isLoadingCalories,
    required this.calories,
    required this.dailyCalorieGoal,
  });

  final bool desktop;
  final bool isLoadingCalories;
  final double calories;
  final double? dailyCalorieGoal;

  @override
  Widget build(BuildContext context) {
    final goal = dailyCalorieGoal;

    final progress = goal != null && goal > 0
        ? (calories / goal).clamp(0.0, 1.0).toDouble()
        : 0.0;

    final remaining = goal != null ? goal - calories : null;

    final String goalText;

    if (isLoadingCalories) {
      goalText = 'Calculating...';
    } else if (goal != null && goal > 0) {
      goalText = '${goal.toStringAsFixed(0)} kcal';
    } else {
      goalText = 'Complete profile';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 340;

        final circleSize = desktop
            ? 105.0
            : isCompact
            ? 105.0
            : 124.0;

        // Increased mobile height to prevent RenderFlex overflow.
        final cardHeight = desktop ? 215.0 : 225.0;
        final cardPadding = desktop ? 13.0 : 17.0;

        Widget progressCircle() {
          return SizedBox(
            width: circleSize,
            height: circleSize,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, child) {
                        return CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isLoadingCalories
                              ? '...'
                              : calories.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 22 : 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'kcal eaten',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        Widget remainingInfo() {
          if (goal == null || isLoadingCalories) {
            return const SizedBox.shrink();
          }

          final isOver = remaining! < 0;

          return Container(
            margin: EdgeInsets.only(top: desktop ? 5 : 6),
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 10 : 10,
              vertical: desktop ? 6 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: desktop ? 25 : 27,
                  height: desktop ? 25 : 27,
                  decoration: BoxDecoration(
                    color: isOver
                        ? AppColors.terracotta.withOpacity(0.9)
                        : AppColors.gold.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isOver
                        ? Icons.warning_amber_rounded
                        : Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: desktop ? 15 : 17,
                  ),
                ),
                SizedBox(width: desktop ? 7 : 7),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOver ? 'DAILY LIMIT EXCEEDED' : 'CALORIES REMAINING',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: desktop ? 7 : 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOver
                            ? '${remaining!.abs().toStringAsFixed(0)} kcal over'
                            : '${remaining!.toStringAsFixed(0)} kcal left',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isOver
                              ? const Color(0xFFFFD1B9)
                              : const Color(0xFFFFE8D8),
                          fontSize: desktop ? 13 : 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          height: cardHeight,
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF193C27), Color(0xFF2C7045), Color(0xFF438B58)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -25,
                top: -45,
                child: Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'YOUR DAILY GOAL 🎯',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 9 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: desktop ? 4 : 6),
                        Text(
                          'Calories\nTracker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 19 : 21,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: desktop ? 4 : 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: desktop ? 8 : 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            goal == null ? goalText : 'Goal: $goalText',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: desktop ? 9 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        remainingInfo(),
                      ],
                    ),
                  ),
                  SizedBox(width: desktop ? 5 : 8),
                  progressCircle(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
