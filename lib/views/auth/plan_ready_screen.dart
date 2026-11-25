import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mealio/views/home/home_screen.dart';
import 'package:mealio/core/utils/calorie_calculator.dart';

class PlanReadyScreen extends StatefulWidget {
  const PlanReadyScreen({super.key});

  @override
  State<PlanReadyScreen> createState() => _PlanReadyScreenState();
}

class _PlanReadyScreenState extends State<PlanReadyScreen>
    with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF2C5E3B);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color background = Color(0xFFF3EFEA);
  static const Color cream = Color(0xFFF9E4D4);
  static const Color terracotta = Color(0xFFC86D51);
  static const Color mutedGreen = Color(0xFF5A735E);
  static const Color lightGreen = Color(0xFFE5EEDD);
  static const Color waterBlue = Color(0xFF69AFC5);

  late AnimationController floatingController;
  late AnimationController entranceController;

  String userName = 'there';

  double dailyCalories = 0;
  double dailyWater = 2.0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    loadPlan();
  }

  @override
  void dispose() {
    floatingController.dispose();
    entranceController.dispose();
    super.dispose();
  }

  double readDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // LOAD USER PLAN FROM FIRESTORE

  Future<void> loadPlan() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Please sign in again.';
      });

      entranceController.forward();
      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        throw Exception('User profile not found.');
      }

      final data = document.data() ?? {};

      final name =
          (data['name'] ?? data['fullName'] ?? user.displayName ?? 'there')
              .toString()
              .trim();

      final weight = CalorieCalculator.number(data['weight']);
      final height = CalorieCalculator.number(data['height']);
      final age = CalorieCalculator.number(data['age']);

      final gender = (data['gender'] ?? 'Female').toString();

      final activityLevel = data['activityLevel'];

      final healthGoal = (data['healthGoal'] ?? '').toString();

      // Validate required profile information.
      if (weight <= 0 || height <= 0 || age <= 0) {
        throw Exception('User profile data is incomplete.');
      }

      // Uses the shared calorie calculation (same as the BMI screen).
      final calorieGoal = CalorieCalculator.calculateCalories(
        weight: weight,
        height: height,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        healthGoal: healthGoal,
      );

      if (calorieGoal <= 0) {
        throw Exception('Invalid calorie goal.');
      }

      // Estimated daily water goal: 35 ml per kg.
      double waterGoal = (weight * 0.035 * 10).round() / 10;

      waterGoal = waterGoal.clamp(1.5, 3.5).toDouble();

      if (!mounted) return;

      setState(() {
        userName = name.isEmpty ? 'there' : name;
        dailyCalories = calorieGoal;
        dailyWater = waterGoal;
        isLoading = false;
        errorMessage = null;
      });

      entranceController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'We could not load your personal goals. Please check your profile information.';
      });

      entranceController.forward();
    }
  }

  void startJourney() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Widget floatingIcon(IconData icon, Color color, double size, double offset) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin(floatingController.value * math.pi) * offset,
          ),
          child: child,
        );
      },
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget buildHeroIllustration() {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          decorativeCircle(185, lightGreen.withOpacity(0.8)),
          decorativeCircle(145, Colors.white.withOpacity(0.65)),

          Positioned(
            top: 12,
            right: 45,
            child: floatingIcon(Icons.auto_awesome_rounded, terracotta, 28, 9),
          ),

          Positioned(
            top: 48,
            left: 35,
            child: floatingIcon(Icons.eco_rounded, primaryGreen, 30, 12),
          ),

          Positioned(
            bottom: 32,
            right: 32,
            child: floatingIcon(Icons.water_drop_rounded, waterBlue, 28, 10),
          ),

          Positioned(
            bottom: 35,
            left: 45,
            child: floatingIcon(
              Icons.favorite_rounded,
              terracotta.withOpacity(0.8),
              24,
              8,
            ),
          ),

          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: cream,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.12),
                  blurRadius: 25,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: const Icon(Icons.spa_rounded, color: primaryGreen, size: 65),
          ),

          Positioned(
            right: 75,
            top: 85,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: primaryGreen,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget animatedNumber({
    required double value,
    required String suffix,
    required double fontSize,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, currentValue, child) {
        return Text(
          '${currentValue.toStringAsFixed(0)}$suffix',
          style: TextStyle(
            color: darkGreen,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        );
      },
    );
  }

  // CALORIES GOAL CARD

  Widget buildCaloriesGoal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: cream.withOpacity(0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: terracotta,
              size: 34,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY CALORIE GOAL',
                  style: TextStyle(
                    color: mutedGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                animatedNumber(value: dailyCalories, suffix: '', fontSize: 29),

                const Text(
                  'kcal per day',
                  style: TextStyle(color: mutedGreen, fontSize: 12),
                ),
              ],
            ),
          ),

          const Icon(Icons.auto_awesome_rounded, color: terracotta, size: 23),
        ],
      ),
    );
  }

  // WATER GOAL CARD

  Widget buildWaterGoal() {
    final cups = (dailyWater * 4).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: waterBlue.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: waterBlue.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3F6),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: waterBlue,
              size: 34,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY WATER GOAL',
                  style: TextStyle(
                    color: mutedGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                animatedNumber(value: dailyWater, suffix: ' L', fontSize: 29),

                Text(
                  'Approximately $cups cups a day',
                  style: const TextStyle(color: mutedGreen, fontSize: 12),
                ),
              ],
            ),
          ),

          floatingIcon(
            Icons.water_drop_rounded,
            waterBlue.withOpacity(0.7),
            26,
            5,
          ),
        ],
      ),
    );
  }

  // BENEFITS

  Widget buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your journey includes',
            style: TextStyle(
              color: darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              benefitItem(Icons.restaurant_rounded, 'Meal\nTracking'),

              benefitItem(Icons.water_drop_rounded, 'Water\nTracking'),

              benefitItem(Icons.insights_rounded, 'Progress\nTracking'),
            ],
          ),
        ],
      ),
    );
  }

  Widget benefitItem(IconData icon, String title) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryGreen, size: 24),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // MAIN BUTTON

  Widget buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: startJourney,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 7,
          shadowColor: primaryGreen.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start My Healthy Journey',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),

            SizedBox(width: 10),

            Icon(Icons.arrow_forward_rounded, size: 21),
          ],
        ),
      ),
    );
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 850;

                  return Stack(
                    children: [
                      Positioned(
                        top: -70,
                        right: -65,
                        child: decorativeCircle(210, cream.withOpacity(0.45)),
                      ),

                      Positioned(
                        bottom: -80,
                        left: -65,
                        child: decorativeCircle(
                          220,
                          lightGreen.withOpacity(0.6),
                        ),
                      ),

                      Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 35 : 22,
                            vertical: 22,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: entranceController,
                                curve: Curves.easeOut,
                              ),
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0, 0.07),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: entranceController,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.eco_rounded,
                                          color: primaryGreen,
                                          size: 27,
                                        ),

                                        const SizedBox(width: 7),

                                        const Text(
                                          'MEALIO',
                                          style: TextStyle(
                                            color: darkGreen,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    buildHeroIllustration(),

                                    Text(
                                      "You're All Set, $userName!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontSize: isDesktop ? 32 : 27,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(height: 9),

                                    const Text(
                                      'Your personal wellness journey starts here.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: mutedGreen,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    if (errorMessage != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(
                                          bottom: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cream,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          errorMessage!,
                                          style: const TextStyle(
                                            color: darkGreen,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                    if (errorMessage == null) ...[
                                      if (isDesktop)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: buildCaloriesGoal(),
                                            ),

                                            const SizedBox(width: 15),

                                            Expanded(child: buildWaterGoal()),
                                          ],
                                        )
                                      else
                                        Column(
                                          children: [
                                            buildCaloriesGoal(),

                                            const SizedBox(height: 13),

                                            buildWaterGoal(),
                                          ],
                                        ),
                                    ],

                                    const SizedBox(height: 20),

                                    buildBenefits(),

                                    const SizedBox(height: 25),

                                    if (errorMessage == null)
                                      buildStartButton()
                                    else
                                      SizedBox(
                                        width: double.infinity,
                                        height: 58,
                                        child: ElevatedButton(
                                          onPressed: loadPlan,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryGreen,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(19),
                                            ),
                                          ),
                                          child: const Text(
                                            'Try Again',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 15),

                                    const Text(
                                      'Small steps. Big changes. 💚',
                                      style: TextStyle(
                                        color: mutedGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
