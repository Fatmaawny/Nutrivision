import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/views/home/widgets/calories_plate_card.dart';
import 'package:mealio/views/home/widgets/feature_buttons.dart';
import 'package:mealio/views/home/widgets/healthy_reminder.dart';
import 'package:mealio/views/home/widgets/home_header.dart';
import 'package:mealio/views/home/widgets/nutrition_grid.dart';
import 'package:mealio/views/home/widgets/section_title.dart';
import 'package:mealio/views/water/widgets/water_home_card.dart';

class DesktopHomeContent extends StatelessWidget {
  const DesktopHomeContent({
    super.key,
    required this.isLoading,
    required this.isLoadingCalories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dailyCalorieGoal,
    required this.userName,
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
  final VoidCallback onLogout;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenBmi;
  final Future<void> Function() onRefreshCalories;
  final Future<void> Function() onRefreshUser;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await onRefreshUser();
        await onRefreshCalories();
      },
      color: AppColors.primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(35, 30, 35, 40),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DesktopHomeHeader(
                          isLoading: isLoading,
                          userName: userName,
                          onLogout: onLogout,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(color: const Color(0xFFE4EADF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // WELCOME + CALORIES CARDS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 850;

                      Widget welcomeCard() {
                        return Container(
                          // FIX: Match the calories card height.
                          height: 215,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF193C27),
                                Color(0xFF2C7045),
                                Color(0xFF438B58),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.17),
                                blurRadius: 22,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -12,
                                top: -35,
                                child: Container(
                                  width: 165,
                                  height: 165,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 75,
                                bottom: -65,
                                child: Container(
                                  width: 125,
                                  height: 125,
                                  decoration: BoxDecoration(
                                    color: AppColors.terracotta.withOpacity(
                                      0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.13),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'YOUR HEALTHY SPACE  ✨',
                                      style: TextStyle(
                                        color: Color(0xFFFFE8D8),
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Welcome back, ${userName.split(' ').first}!',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Every healthy choice brings you closer\nto a better version of yourself.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.favorite_rounded,
                                        color: Color(0xFFFFB69B),
                                        size: 16,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'Eat well. Feel good. Live better.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      if (compact) {
                        return Column(
                          children: [
                            welcomeCard(),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 215,
                              child: CaloriesPlateCard(
                                desktop: true,
                                isLoadingCalories: isLoadingCalories,
                                calories: calories,
                                dailyCalorieGoal: dailyCalorieGoal,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: welcomeCard()),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 215,
                              child: CaloriesPlateCard(
                                desktop: true,
                                isLoadingCalories: isLoadingCalories,
                                calories: calories,
                                dailyCalorieGoal: dailyCalorieGoal,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 34),

                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EFDF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: AppColors.primaryGreen,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Nutrition",
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your daily nutrition overview',
                              style: TextStyle(
                                color: AppColors.secondaryGreenText.withOpacity(
                                  0.9,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8D8),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Text(
                          'DAILY STATS',
                          style: TextStyle(
                            color: Color(0xFFC86D51),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 19),
                  NutritionGrid(
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                  ),
                  const SizedBox(height: 35),

                  SectionTitle(
                    'Water Intake',
                    'Stay hydrated through the day',
                    '💧',
                  ),
                  const SizedBox(height: 19),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const WaterHomeCard(),
                    ),
                  ),
                  const SizedBox(height: 35),

                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8D8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.terracotta,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Mealio',
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Everything you need for your healthy journey',
                              style: TextStyle(
                                color: AppColors.secondaryGreenText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 19),
                  FeatureButtons(
                    onPageChanged: onPageChanged,
                    onOpenBmi: onOpenBmi,
                  ),
                  const SizedBox(height: 28),
                  HealthyReminder(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
