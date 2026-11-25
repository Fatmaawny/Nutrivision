
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealio/core/utils/calorie_calculator.dart';
import 'package:mealio/data/services/weekly_progress_service.dart';

// MEALIO COLORS
const Color primaryGreen = Color(0xFF2C5E3B);
const Color darkGreen = Color(0xFF1E3F29);
const Color backgroundColor = Color(0xFFF3EFEA);
const Color creamColor = Color(0xFFF9E4D4);
const Color terracottaColor = Color(0xFFC86D51);
const Color mutedColor = Color(0xFF718078);
const Color lightGreen = Color(0xFFE7F0E5);

class BmiScreen extends StatelessWidget {
  BmiScreen({super.key});

  // NUMBER CONVERSION
  static double number(dynamic value) => CalorieCalculator.number(value);

  // ACTIVITY MULTIPLIER
  static double getActivityMultiplier(dynamic activity) =>
      CalorieCalculator.getActivityMultiplier(activity);

  // BMI CALCULATION
  double calculateBmi(double weight, double height) {
    if (weight <= 0 || height <= 0) return 0;

    double heightInMeters = height / 100;

    return weight / (heightInMeters * heightInMeters);
  }

  // BMI CATEGORY
  String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Weight';
    if (bmi < 30) return 'Overweight';

    return 'Obesity';
  }

  // BMI ADVICE
  String getBmiAdvice(double bmi) {
    if (bmi < 18.5) {
      return 'Consider following a balanced nutrition plan to reach a healthy weight.';
    }

    if (bmi < 25) {
      return 'Great job! Your BMI is within the healthy range. Keep maintaining your healthy habits.';
    }

    if (bmi < 30) {
      return 'Small, consistent lifestyle changes can help you move toward a healthier range.';
    }

    return 'Consider discussing a suitable nutrition and activity plan with a healthcare professional.';
  }

  // DAILY CALORIES CALCULATION
  static double calculateCalories({
    required double weight,
    required double height,
    required double age,
    required String gender,
    required dynamic activityLevel,
    required String healthGoal,
  }) {
    return CalorieCalculator.calculateCalories(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      healthGoal: healthGoal,
    );
  }

  // HEALTHY WEIGHT CALCULATION
  double calculateHealthyWeight(double height, double bmi) {
    if (height <= 0) return 0.0;

    double heightInMeters = height / 100;

    return bmi * heightInMeters * heightInMeters;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Please login to view your health information.',
            style: TextStyle(color: darkGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Unable to load your information.',
                style: TextStyle(color: darkGreen),
              ),
            );
          }

          Map<String, dynamic> data =
              snapshot.data!.data() ?? {};

          double weight = BmiScreen.number(data['weight']);
          double height = BmiScreen.number(data['height']);
          double age = BmiScreen.number(data['age']);

          String gender =
          (data['gender'] ?? 'Female').toString();

          String goal =
          (data['healthGoal'] ?? '').toString();

          dynamic activity = data['activityLevel'];

          if (weight <= 0 || height <= 0 || age <= 0) {
            return Center(
              child: Text(
                'Please complete your profile first.',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            );
          }

          double bmi = calculateBmi(weight, height);

          double calories = BmiScreen.calculateCalories(
            weight: weight,
            height: height,
            age: age,
            gender: gender,
            activityLevel: activity,
            healthGoal: goal,
          );

          double healthyMin =
          calculateHealthyWeight(height, 18.5);

          double healthyMax =
          calculateHealthyWeight(height, 24.9);
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 650),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 25),

                      _buildBmiCard(bmi),
                      SizedBox(height: 24),

                      _buildSectionTitle('Your Measurements'),
                      SizedBox(height: 13),

                      Row(
                        children: [
                          Expanded(
                            child: _measurementCard(
                              icon: Icons.monitor_weight_outlined,
                              title: 'Weight',
                              value: '${weight.toStringAsFixed(1)} kg',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _measurementCard(
                              icon: Icons.height_rounded,
                              title: 'Height',
                              value: '${height.toStringAsFixed(0)} cm',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _measurementCard(
                              icon: Icons.cake_outlined,
                              title: 'Age',
                              value: '${age.toStringAsFixed(0)} years',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 25),

                      _buildSectionTitle('Healthy Weight Range'),
                      SizedBox(height: 13),

                      _healthyWeightCard(healthyMin, healthyMax),

                      SizedBox(height: 25),

                      _buildSectionTitle('Daily Calories'),
                      SizedBox(height: 13),

                      _caloriesCard(calories),

                      if (calories > 0 && calories < 1200) ...[
                        SizedBox(height: 12),
                        _calorieWarningCard(),
                      ],

                      SizedBox(height: 25),

                      _buildSectionTitle('Your Health Insight'),
                      SizedBox(height: 13),

                      _insightsCard(bmi),

                      SizedBox(height: 25),

                      Center(
                        child: Text(
                          'MEALIO • Your journey to a healthier you',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: primaryGreen,
                size: 19,
              ),
            ),
          ),

          SizedBox(width: 12),

          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: primaryGreen,
              size: 24,
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI & Calories',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Understand your body better',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BMI CARD
  Widget _buildBmiCard(double bmi) {
    double progress = (bmi / 40).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: Duration(milliseconds: 1300),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkGreen, primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withOpacity(0.16),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your BMI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    color: creamColor,
                    size: 21,
                  ),
                ],
              ),

              SizedBox(height: 22),

              SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: animatedProgress,
                        strokeWidth: 12,
                        backgroundColor:
                        Colors.white.withOpacity(0.15),
                        valueColor:
                        AlwaysStoppedAnimation(creamColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'kg / m²',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  getBmiCategory(bmi),
                  style: TextStyle(
                    color: creamColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              SizedBox(height: 12),

              Text(
                'The circle shows your BMI on a scale from 0 to 40.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: darkGreen,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // MEASUREMENT CARD
  Widget _measurementCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        height: 130,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withOpacity(0.04),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primaryGreen,
              size: 26,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 5),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEALTHY WEIGHT CARD
  Widget _healthyWeightCard(double min, double max) {
    return Container(
      padding: EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.monitor_weight_outlined,
                  color: primaryGreen,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Recommended weight range',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _weightValue('Minimum', min),
              _weightValue('Maximum', max),
            ],
          ),

          SizedBox(height: 17),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 9,
              backgroundColor: lightGreen,
              valueColor: AlwaysStoppedAnimation(primaryGreen),
            ),
          ),

          SizedBox(height: 12),

          Text(
            'This range is based on the standard healthy BMI range.',
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // WEIGHT VALUE
  Widget _weightValue(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: mutedColor,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 5),
        Text(
          '${value.toStringAsFixed(1)} kg',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // DAILY CALORIES CARD
  Widget _caloriesCard(double calories) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: terracottaColor,
              size: 30,
            ),
          ),

          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated daily needs',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 5),

                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: calories),
                  duration: Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Text(
                      '${value.round()} kcal',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LOW CALORIE WARNING
  Widget _calorieWarningCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: terracottaColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: terracottaColor,
            size: 25,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calorie Intake Warning',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Your estimated daily calories are below 1200 kcal. '
                      'This is an alert for review, not a universal safety limit. '
                      'Please consult a qualified nutrition professional '
                      'before following this calorie target.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEALTH INSIGHTS CARD
  Widget _insightsCard(double bmi) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: lightGreen,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: primaryGreen,
            ),
          ),

          SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A little insight for you',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  getBmiAdvice(bmi),
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
